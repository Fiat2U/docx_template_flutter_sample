# docx_template_flutter_sample
A sample Flutter app that demonstrate how to use the `docx_template` package to generate Word documents from templates.

## Generate Document (Official Example)

| Word Document Template            | Generated Word Document            |
| --------------------------------- | ---------------------------------- |
| ![](./assets/template-word-1.png) | ![](./assets/generated-word-1.png) |
| ![](./assets/template-word-2.png) | ![](./assets/generated-word-2.png) |

## Take a Photo and Generate a Document

| Simple Template      | Generated Word Document            |
| --------------------------------- | ---------------------------------- |
| ![](./assets/simple-template.png) | ![](./assets/photo-document.png) |

## Note

### Android

`android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.docx_template_flutter_sample">
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <application
        android:requestLegacyExternalStorage="true"
...
```

To write Word documents in the public Download directory, which is `/storage/emulated/0/Download/`, of Android phones, it is necessary to include `android:requestLegacyExternalStorage="true"` in the app's manifest file.

## References

- [docx_template 0.3.4](https://pub.dev/packages/docx_template)
- [docx_template_dart](https://github.com/PavelS0/docx_template_dart)
- ~~[Word file gets corrupted](https://github.com/PavelS0/docx_template_dart/issues/37)~~
- [Attempt to fix archive saving ](https://github.com/PavelS0/docx_template_dart/commit/de19046cca148e96e02765ac297e487125569fc5)
- [Modify the App Manifest (androidManifest.xml)](https://www.ibm.com/docs/en/trusteer-mobile-sdk/5.2?topic=qsta-step-1-modify-app-manifest-androidmanifestxml)
- [Icons8](https://icons8.com/license)
