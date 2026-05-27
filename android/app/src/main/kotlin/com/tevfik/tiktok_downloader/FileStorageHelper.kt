package com.tevfik.tiktok_downloader

import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import java.io.File
import java.io.FileInputStream

object FileStorageHelper {
    private const val TAG = "FileStorageHelper"
    private const val SUBDIR = "TikTok Downloader"
    private val FILENAME_ID_RE = Regex("_(\\d+)\\.mp4$")

    private fun downloadsCollection(): Uri =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Downloads.EXTERNAL_CONTENT_URI
        } else {
            // Legacy fallback — Android 9 and below treat Downloads as a regular dir.
            MediaStore.Files.getContentUri("external")
        }

    @JvmStatic
    fun copyFromCacheToMediaStore(
        context: Context,
        cacheFile: File,
        displayName: String
    ): Uri? {
        if (!cacheFile.exists()) {
            Log.w(TAG, "cache file missing: ${cacheFile.absolutePath}")
            return null
        }

        val resolver = context.contentResolver
        val collection = downloadsCollection()
        val safeName = sanitizeFilename(displayName)

        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, safeName)
            put(MediaStore.MediaColumns.MIME_TYPE, "video/mp4")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    Environment.DIRECTORY_DOWNLOADS + "/" + SUBDIR + "/"
                )
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
        }

        val uri = resolver.insert(collection, values) ?: return null

        try {
            resolver.openOutputStream(uri, "w")?.use { out ->
                FileInputStream(cacheFile).use { input ->
                    input.copyTo(out, bufferSize = 64 * 1024)
                }
            } ?: run {
                Log.w(TAG, "openOutputStream returned null for $uri")
                resolver.delete(uri, null, null)
                return null
            }
        } catch (t: Throwable) {
            Log.e(TAG, "copy failed", t)
            try {
                resolver.delete(uri, null, null)
            } catch (_: Throwable) {
            }
            return null
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val finalize = ContentValues().apply {
                put(MediaStore.MediaColumns.IS_PENDING, 0)
            }
            try {
                resolver.update(uri, finalize, null, null)
            } catch (t: Throwable) {
                Log.w(TAG, "finalize update failed", t)
            }
        }
        return uri
    }

    /**
     * Queries MediaStore for existing files under Downloads/TikTok Downloader/ and
     * returns the set of TikTok IDs (the digits after the last underscore).
     */
    @JvmStatic
    fun listExistingDownloadedIds(context: Context): Set<String> {
        val ids = HashSet<String>()
        val collection = downloadsCollection()
        val projection = arrayOf(
            MediaStore.MediaColumns._ID,
            MediaStore.MediaColumns.DISPLAY_NAME,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
                MediaStore.MediaColumns.RELATIVE_PATH
            else
                MediaStore.MediaColumns.DATA
        )
        val selection: String?
        val selectionArgs: Array<String>?
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            selection = MediaStore.MediaColumns.RELATIVE_PATH + " LIKE ?"
            selectionArgs = arrayOf(
                Environment.DIRECTORY_DOWNLOADS + "/" + SUBDIR + "/%"
            )
        } else {
            selection = MediaStore.MediaColumns.DATA + " LIKE ?"
            selectionArgs = arrayOf("%/" + SUBDIR + "/%")
        }

        try {
            context.contentResolver.query(
                collection, projection, selection, selectionArgs, null
            )?.use { cursor ->
                val nameCol = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DISPLAY_NAME)
                while (cursor.moveToNext()) {
                    val name = cursor.getString(nameCol) ?: continue
                    val match = FILENAME_ID_RE.find(name) ?: continue
                    ids.add(match.groupValues[1])
                }
            }
        } catch (t: Throwable) {
            Log.w(TAG, "listExistingDownloadedIds failed", t)
        }
        return ids
    }

    /**
     * Python-friendly bridge. Used as `storage_helper` in [downloader.process_queue].
     * Returns the inserted URI as String, or null on failure.
     */
    class PythonBridge(private val context: Context) {
        fun copy_to_media_store(cachePath: String?, displayName: String?): String? {
            if (cachePath == null || displayName == null) return null
            val uri = copyFromCacheToMediaStore(context, File(cachePath), displayName)
                ?: return null
            return uri.toString()
        }

        fun list_existing_ids(): List<String> {
            return listExistingDownloadedIds(context).toList()
        }
    }

    private fun sanitizeFilename(name: String): String {
        // MediaStore is strict about path separators; collapse any to underscore.
        val cleaned = name.replace(Regex("[\\\\/]+"), "_").trim()
        return if (cleaned.isEmpty()) "video.mp4" else cleaned
    }

    @Suppress("unused")
    fun deleteUri(context: Context, uri: Uri) {
        try {
            context.contentResolver.delete(uri, null, null)
        } catch (t: Throwable) {
            Log.w(TAG, "deleteUri failed", t)
        }
    }

    @Suppress("unused")
    fun uriFromId(id: Long): Uri = ContentUris.withAppendedId(downloadsCollection(), id)
}
