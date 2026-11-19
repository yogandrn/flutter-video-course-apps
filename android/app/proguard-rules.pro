# Flutter embedding + keep rules plugin sudah ditambahkan otomatis oleh Flutter Gradle plugin
# dan oleh consumer rules tiap plugin. Di sini hanya yang biasanya kurang.

# Flutter deferred components mereferensikan Play Core. App ini tidak memakainya,
# tanpa ini R8 gagal dengan "Missing class com.google.android.play.core..."
-dontwarn com.google.android.play.core.**

# video_player: ExoPlayer lama dan Media3 baru (tergantung versi plugin)
-dontwarn com.google.android.exoplayer2.**
-dontwarn androidx.media3.**

# Crash report tetap punya nomor baris (dipetakan lewat mapping.txt)
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile