# Flutter default ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.engine.landing.** { *; }

# Keep annotations
-keepattributes *Annotation*

# sqflite
-keep class sqflite.** { *; }

# Keep model classes used by sqflite
-keep class com.lucero.ojt.ojt_tracker.** { *; }
