# JudoModel

Current model target is **JudoModelV2**

## Update procedure:
1. Update `Sources/JudoModel/CurrentModel.stencil` file `modelName` with current value (eg. JudoModelV2)
1. Update `.sourcery.yml` with a path to a current model target path (eg. `Sources/JudoModelV2`)
1. Run `sourcery --config .sourcery.yml` to regenerate `CurrentModel.generated.swift`

When V2 model is ready and we must be able to detect and migrate V1 models.
Introduce a `probe` function for each model type to determine if the model can be read

```swift
if JudoModelV1.probe(data) {
 JudoModelV1.read(data)
} else {
 JudoModelV2.read(data)
}
```

```swift
import Foundation

import JudoModelV2
import JudoModelV1
```

When migrating between nodes that have not changed structually use `unsafeBitCast(...)`
To avoid boilerplate code when migrating you can use the `Mirror` API to translate same named attributes

```swift
public func read(data: Data) -> JudoModelV2.Document {
    //
}

private func migrateV1ToV2(_from: JudoModelV1.Document) -> JudoModelV2.Document {
    //
}

private func migrateV2ToV3(_from: JudoModelV1.Document) -> JudoModelV2.Document {
    //
}
```
