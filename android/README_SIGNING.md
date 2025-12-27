## Android Play Store signing (JKS)

This project expects a release keystore at:

- `android/app/release-keystore.jks`

And signing credentials in:

- `android/key.properties` (**ignored by git**)

### key.properties format

Use `android/key.properties.example` as a template:

- `storePassword`
- `keyPassword`
- `keyAlias`
- `storeFile` (relative to `android/`)

### Important

- Never commit `android/key.properties` or any `.jks` file.
- Back up the keystore + passwords securely. Losing them can block future updates.


