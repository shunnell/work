locals {
  # Mutally exclusive action lists which will be combined to form policies
  actions = {
    codeartifact = {
      pull = [
        "codeartifact:Describe*",
        "codeartifact:Get*",
        "codeartifact:List*",
        "codeartifact:ReadFromRepository",
      ]
      push = [
        "codeartifact:CopyPackageVersions",
        "codeartifact:PublishPackageVersion",
        "codeartifact:PutPackageMetadata",
        "codeartifact:PutPackageOriginConfiguration",
        "codeartifact:TagResource",
        "codeartifact:UntagResource",
        "codeartifact:UpdatePackageGroup",
        "codeartifact:UpdatePackageGroupOriginConfiguration",
        "codeartifact:UpdatePackageVersionsStatus",
        "codeartifact:DeletePackageVersions",
        "codeartifact:DeletePackage",
        "codeartifact:DeletePackageGroup"
      ]
    }
  }
}