# NB: This file is largely copied from code in https://wizio-public-fedramp.s3-us-gov-west-1.amazonaws.com/deployment-v2/aws/wiz-aws-native-terraform-terraform-module.zip
# We cannot use that module directly at this time, potentially ever (see README.md for details on why).
# This file has been "left alone" so that future upstream changes from that module can be easily integrated. That's why
# this file is not using iam_policy_document data resources, or our iam/policy module, etc. Switching to use those things
# is not a good idea, for two reasons:
# 1. Makes integration of changes from upstream harder, since upstream is written like this code, not ours.
# 2. Makes eventual *migration* to use the upstream module harder (if Wiz fixes the issues discussed in README.md);
#    if we did rewrite this code and then migrate, the migration would include behavioral changes caused by stopping
#    use of BESPIN-internal tools and patterns (e.g. our iam/policy module).
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

# Create IAM inline policy - WizFullPolicy
resource "aws_iam_policy" "wiz_full_policy_0" {
  # Some of the Wiz builtin self-health checking wants this policy to have a specific name. Things seem to work if it
  # has a different name, but this generates alert noise, so we break the WizFullPolicy1/2/3 naming convention here
  # to satisfy those checkers.
  name = "WizFullPolicy"

  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "account:GetContactInformation",
          "acm-pca:GetCertificateAuthorityCertificate",
          "acm:GetCertificate",
          "amplify:GetApp",
          "amplify:GetBackendEnvironment",
          "amplify:ListApps",
          "amplify:ListBackendEnvironments",
          "amplify:ListBranches",
          "amplify:ListDomainAssociations",
          "amplify:ListTagsForResource",
          "amplifybackend:GetBackend",
          "aoss:BatchGetCollection",
          "aoss:GetAccessPolicy",
          "aoss:GetSecurityPolicy",
          "aoss:ListAccessPolicies",
          "aoss:ListCollections",
          "aoss:ListSecurityPolicies",
          "aoss:ListTagsForResource",
          "apigateway:GET",
          "appconfig:GetConfigurationProfile",
          "appconfig:ListApplications",
          "appconfig:ListConfigurationProfiles",
          "appconfig:ListTagsForResource",
          "appfabric:GetAppBundle",
          "appfabric:ListAppBundles",
          "appfabric:ListTagsForResource",
          "appflow:DescribeFlow",
          "applicationinsights:ListApplications",
          "applicationinsights:ListTagsForResource",
          "appstream:DescribeFleets",
          "appstream:DescribeStacks",
          "appstream:DescribeUserStackAssociations",
          "appstream:ListAssociatedFleets",
          "appstream:ListTagsForResource",
          "appsync:GetApiAssociation",
          "aps:DescribeAlertManagerDefinition",
          "aps:DescribeLoggingConfiguration",
          "aps:ListWorkspaces",
          "auditmanager:GetAssessment",
          "backup-gateway:GetGateway",
          "backup-gateway:ListGateways",
          "backup-gateway:ListTagsForResource",
          "backup:GetBackupPlan",
          "backup:GetBackupSelection",
          "bedrock:GetAgent",
          "bedrock:GetAgentActionGroup",
          "bedrock:GetDataSource",
          "bedrock:GetFoundationModelAvailability",
          "bedrock:GetGuardrail",
          "bedrock:GetImportedModel",
          "bedrock:GetKnowledgeBase",
          "bedrock:GetModelImportJob",
          "bedrock:GetProvisionedModelThroughput",
          "bedrock:ListAgentActionGroups",
          "bedrock:ListAgentKnowledgeBases",
          "bedrock:ListAgents",
          "bedrock:ListDataSources",
          "bedrock:ListFoundationModels",
          "bedrock:ListGuardrails",
          "bedrock:ListImportedModels",
          "bedrock:ListKnowledgeBases",
          "bedrock:ListModelImportJobs",
          "bedrock:ListProvisionedModelThroughputs",
          "chatbot:DescribeChimeWebhookConfigurations",
          "chatbot:DescribeSlackChannelConfigurations",
          "chime:GetAccount",
          "clouddirectory:ListTagsForResource",
          "cloudhsm:DescribeClusters",
          "cloudsearch:DescribeAvailabilityOptions",
          "codeconnections:ListConnections",
          "codeconnections:ListHosts",
          "codeconnections:ListTagsForResource",
          "codeguru-reviewer:DescribeRepositoryAssociation",
          "codeguru-reviewer:ListRepositoryAssociations",
          "codepipeline:ListTagsForResource",
          "codestar-notifications:DescribeNotificationRule",
          "codestar-notifications:ListNotificationRules",
          "databrew:DescribeRecipe",
          "databrew:ListRecipes",
          "datazone:GetDomain",
          "datazone:ListDomains",
          "datazone:ListTagsForResource",
          "detective:ListOrganizationAdminAccount",
          "detective:ListTagsForResource",
          "dlm:GetLifecyclePolicies",
          "dlm:GetLifecyclePolicy",
          "docdb-elastic:GetCluster",
          "docdb-elastic:GetClusterSnapshot",
          "docdb-elastic:ListClusterSnapshots",
          "docdb-elastic:ListTagsForResource",
          "ds:DescribeSettings",
          "ds:DescribeSharedDirectories",
          "ds:DescribeTrusts",
          "ds:ListTagsForResource",
          "dynamodb:GetResourcePolicy",
          "ec2:GetAllowedImagesSettings",
          "ec2:GetInstanceMetadataDefaults",
          "ec2:GetSnapshotBlockPublicAccessState",
          "ecr:BatchGetImage",
          "ecr:DescribePullThroughCacheRules",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "eks:DescribeAccessEntry",
          "eks:DescribePodIdentityAssociation",
          "eks:ListAssociatedAccessPolicies",
          "eks:ListPodIdentityAssociations",
          "entityresolution:GetMatchingWorkflow",
          "entityresolution:GetSchemaMapping",
          "entityresolution:ListIdNamespaces",
          "entityresolution:ListMatchingWorkflows",
          "entityresolution:ListSchemaMappings",
          "entityresolution:ListTagsForResource",
          "fis:GetExperiment",
          "fis:GetExperimentTemplate",
          "fis:ListExperimentTemplates",
          "fis:ListExperiments",
          "frauddetector:ListTagsForResource",
          "gamelift:DescribeAlias",
          "gamelift:DescribeBuild",
          "gamelift:DescribeFleetAttributes",
          "gamelift:DescribeGameServerGroup",
          "gamelift:DescribeGameSessionQueues",
          "gamelift:DescribeMatchmakingConfigurations",
          "gamelift:DescribeMatchmakingRuleSets",
          "gamelift:DescribeScript",
          "geo:DescribeGeofenceCollection",
          "geo:DescribeKey",
          "geo:DescribeMap",
          "geo:DescribePlaceIndex",
          "geo:DescribeRouteCalculator",
          "geo:DescribeTracker",
          "geo:ListGeofenceCollections",
          "geo:ListKeys",
          "geo:ListPlaceIndexes",
          "geo:ListRouteCalculators",
          "geo:ListTagsForResource",
          "geo:ListTrackers",
          "glue:GetConnection",
          "identitystore:Describe*",
          "identitystore:List*",
          "internetmonitor:GetMonitor",
          "internetmonitor:ListMonitors",
          "iotanalytics:DescribeChannel",
          "iotanalytics:DescribeDataset",
          "iotanalytics:DescribeDatastore",
          "iotanalytics:DescribePipeline",
          "iotanalytics:ListDatasets",
          "iotanalytics:ListDatastores",
          "iotanalytics:ListPipelines",
          "iotanalytics:ListTagsForResource",
          "iotfleetwise:GetCampaign",
          "iotfleetwise:ListCampaigns",
          "iotfleetwise:ListTagsForResource",
          "iotsitewise:DescribeAssetModel",
          "iotsitewise:DescribePortal",
          "iotsitewise:ListPortals",
          "iotsitewise:ListTagsForResource",
          "kendra:DescribeDataSource",
          "kinesisanalytics:DescribeApplication",
          "kinesisvideo:GetDataEndpoint",
          "lambda:GetFunction",
          "lambda:GetLayerVersion",
          "lightsail:GetRelationalDatabases",
          "lookoutequipment:DescribeDataset",
          "lookoutequipment:DescribeInferenceScheduler",
          "lookoutequipment:DescribeModel",
          "lookoutequipment:ListInferenceSchedulers",
          "lookoutequipment:ListModels",
          "lookoutequipment:ListTagsForResource",
          "lookoutvision:DescribeProject",
          "macie2:GetAutomatedDiscoveryConfiguration",
          "macie2:GetFindings",
          "macie2:GetMacieSession",
          "mediaconvert:GetJobTemplate",
          "mediaconvert:GetPreset",
          "mediaconvert:GetQueue",
          "mediaconvert:ListJobTemplates",
          "mediaconvert:ListPresets",
          "mediaconvert:ListQueues",
          "mediaconvert:ListTagsForResource"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "WizFullPolicy"
      },
    ],
    "Version" : "2012-10-17"
  })
}

resource "aws_iam_policy" "wiz_full_policy_1" {
  name = "WizFullPolicy1"

  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "ec2:CopySnapshot",
          "ec2:CreateSnapshot",
          "ec2:DescribeSnapshots",
          "ec2:GetEbsEncryptionByDefault",
          "kms:CreateKey",
          "kms:DescribeKey"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "ec2:CreateTags"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:CreateAction" : [
              "CopySnapshot",
              "CreateSnapshot"
            ]
          }
        },
        "Effect" : "Allow",
        "Resource" : "arn:${data.aws_partition.current.partition}:ec2:*::snapshot/*",
        "Sid" : "AllowWizToCreateTagsOnCreatedAndCopiedSnapshots"
      },
      {
        "Action" : [
          "ec2:CreateVolume"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestTag/wiz" : "auto-gen-volume"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "AllowWizToCreateTaggedVolumes"
      },
      {
        "Action" : [
          "ec2:CreateVolume"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:${data.aws_partition.current.partition}:ec2:*::snapshot/*",
        "Sid" : "AllowWizToCreateTaggedVolumesFromSnapshots"
      },
      {
        "Action" : [
          "ec2:DeleteSnapshot"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:ResourceTag/wiz" : "auto-gen-snapshot"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "ec2:DeleteVolume"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:ResourceTag/wiz" : "auto-gen-volume"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "AllowWizToDeleteTaggedVolumes"
      },
      {
        "Action" : [
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeVolumes"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "WizComplementaryPermissionsForTemporaryVolumes"
      },
      {
        "Action" : [
          "ec2:ModifySnapshotAttribute"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:ResourceTag/wiz" : [
              "auto-gen-snapshot",
              "shareable-resource"
            ]
          }
        },
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "ecr-public:DescribeImages",
          "ecr-public:GetAuthorizationToken",
          "ecr-public:ListTagsForResource",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRegistryPolicy",
          "ecr:ListTagsForResource"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "kms:CreateGrant",
          "kms:ReEncryptFrom"
        ],
        "Condition" : {
          "StringLike" : {
            "kms:ViaService" : "ec2.*.${data.aws_partition.current.dns_suffix}"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "kms:GetKeyPolicy",
          "kms:PutKeyPolicy"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/wiz" : "auto-gen-cmk"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : "cassandra:Select",
        "Effect" : "Allow",
        "Resource" : [
          "arn:${data.aws_partition.current.partition}:cassandra:*:*:/keyspace/system_multiregion_info/table/tables",
          "arn:${data.aws_partition.current.partition}:cassandra:*:*:/keyspace/system_schema/table/columns",
          "arn:${data.aws_partition.current.partition}:cassandra:*:*:/keyspace/system_schema/table/keyspaces",
          "arn:${data.aws_partition.current.partition}:cassandra:*:*:/keyspace/system_schema/table/tables",
          "arn:${data.aws_partition.current.partition}:cassandra:*:*:/keyspace/system_schema_mcs/table/columns",
          "arn:${data.aws_partition.current.partition}:cassandra:*:*:/keyspace/system_schema_mcs/table/keyspaces",
          "arn:${data.aws_partition.current.partition}:cassandra:*:*:/keyspace/system_schema_mcs/table/tables",
          "arn:${data.aws_partition.current.partition}:cassandra:*:*:/keyspace/system_schema_mcs/table/tags"
        ]
      },
      {
        "Action" : "ec2:CreateTags",
        "Condition" : {
          "StringEquals" : {
            "ec2:CreateAction" : "CreateVolume"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "AllowWizToCreateTagsOnCreatedVolumes"
      },
      {
        "Action" : "kms:CreateAlias",
        "Effect" : "Allow",
        "Resource" : [
          "arn:${data.aws_partition.current.partition}:kms:*:*:alias/wizKey",
          "arn:${data.aws_partition.current.partition}:kms:*:*:key/*"
        ]
      }
    ],
    "Version" : "2012-10-17"
  })
}

# Create IAM Managed Policy - WizFullPolicy2
resource "aws_iam_policy" "wiz_full_policy_2" {
  name = "WizFullPolicy2"
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "mediastore:ListTagsForResource",
          "medical-imaging:GetDatastore",
          "medical-imaging:ListDatastores",
          "medical-imaging:ListTagsForResource",
          "memorydb:DescribeSnapshots",
          "memorydb:ListTags",
          "neptune-graph:GetGraph",
          "neptune-graph:ListGraphSnapshots",
          "neptune-graph:ListGraphs",
          "neptune-graph:ListTagsForResource",
          "networkmonitor:GetMonitor",
          "networkmonitor:ListMonitors",
          "payment-cryptography:GetKey",
          "payment-cryptography:ListKeys",
          "payment-cryptography:ListTagsForResource",
          "pipes:DescribePipe",
          "pipes:ListPipes",
          "qbusiness:GetApplication",
          "qldb:DescribeJournalKinesisStream",
          "qldb:ListJournalKinesisStreamsForLedger",
          "qldb:ListTagsForResource",
          "rbin:GetRule",
          "rbin:ListRules",
          "rbin:ListTagsForResource",
          "redshift-serverless:GetScheduledAction",
          "redshift-serverless:ListScheduledActions",
          "resiliencehub:DescribeApp",
          "resiliencehub:ListApps",
          "resiliencehub:ListResiliencyPolicies",
          "resiliencehub:ListTagsForResource",
          "resource-groups:GetAccountSettings",
          "resource-groups:GetGroupConfiguration",
          "resource-groups:GetGroupQuery",
          "resource-groups:GetTags",
          "resource-groups:ListGroups",
          "s3:GetIntelligentTieringConfiguration",
          "s3express:GetBucketPolicy",
          "s3express:ListAllMyDirectoryBuckets",
          "scheduler:GetSchedule",
          "scheduler:ListSchedules",
          "scheduler:ListTagsForResource",
          "serverlessrepo:GetApplication",
          "servicecatalog:DescribePortfolio",
          "servicecatalog:DescribeProductAsAdmin",
          "servicecatalog:SearchProductsAsAdmin",
          "servicediscovery:GetNamespace",
          "servicediscovery:ListNamespaces",
          "servicediscovery:ListTagsForResource",
          "snowball:DescribeJob",
          "sns:GetDataProtectionPolicy",
          "ssm:GetDocument",
          "ssm:GetParameters",
          "sso-directory:Describe*",
          "sso-directory:ListMembersInGroup",
          "states:ListTagsForResource",
          "swf:DescribeDomain",
          "textract:GetAdapter",
          "textract:ListAdapters",
          "textract:ListTagsForResource",
          "timestream:DescribeBatchLoadTask",
          "timestream:DescribeEndpoints",
          "timestream:DescribeScheduledQuery",
          "timestream:ListBatchLoadTasks",
          "timestream:ListDatabases",
          "timestream:ListScheduledQueries",
          "timestream:ListTables",
          "timestream:ListTagsForResource",
          "tnb:GetSolFunctionPackage",
          "tnb:GetSolNetworkPackage",
          "tnb:ListSolFunctionPackages",
          "tnb:ListSolNetworkPackages",
          "transcribe:GetCallAnalyticsJob",
          "transcribe:GetMedicalScribeJob",
          "transcribe:GetMedicalTranscriptionJob",
          "transcribe:GetTranscriptionJob",
          "transcribe:ListMedicalScribeJobs",
          "voiceid:ListDomains",
          "wafv2:GetIPSet",
          "wafv2:GetRuleGroup",
          "wellarchitected:GetWorkload",
          "wellarchitected:ListWorkloads",
          "workmail:GetDefaultRetentionPolicy",
          "workmail:ListAccessControlRules",
          "workmail:ListAvailabilityConfigurations",
          "workmail:ListMailDomains",
          "workmail:ListOrganizations",
          "workmail:ListPersonalAccessTokens",
          "workmail:ListTagsForResource"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "WizFullPolicy2"
      }
    ],
    "Version" : "2012-10-17"
  })
}

# Create Lightsail Scanning Managed Policy
resource "aws_iam_policy" "wiz_lightsail_policy" {
  name  = "WizLightsailScanningPolicy"
  count = var.lightsail-scanning ? 1 : 0
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "ec2:DeleteSnapshot",
          "ec2:ModifySnapshotAttribute"
        ],
        "Condition" : {
          "StringLike" : {
            "ec2:ParentVolume" : "arn:${data.aws_partition.current.partition}:ec2:*:*:volume/vol-ffffffff"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "iam:PutRolePolicy"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:${data.aws_partition.current.partition}:iam::*:role/aws-service-role/lightsail.${data.aws_partition.current.dns_suffix}/AWSServiceRoleForLightsail*"
      },
      {
        "Action" : [
          "lightsail:CreateDiskSnapshot",
          "lightsail:TagResource"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestTag/wiz" : "auto-gen-snapshot"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "lightsail:DeleteDiskSnapshot",
          "lightsail:ExportSnapshot"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/wiz" : "auto-gen-snapshot"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "lightsail:GetDiskSnapshot",
          "lightsail:GetDiskSnapshots",
          "lightsail:GetExportSnapshotRecords"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : "iam:CreateServiceLinkedRole",
        "Condition" : {
          "StringLike" : {
            "iam:AWSServiceName" : "lightsail.${data.aws_partition.current.dns_suffix}"
          }
        },
        "Effect" : "Allow",
        "Resource" : "arn:${data.aws_partition.current.partition}:iam::*:role/aws-service-role/lightsail.${data.aws_partition.current.dns_suffix}/AWSServiceRoleForLightsail*"
      }
    ],
    "Version" : "2012-10-17"
  })
}

# Create Data Scanning Managed Policy
resource "aws_iam_policy" "wiz_policy_data" {
  name  = "WizDataScanningPolicy"
  count = var.data-scanning ? 1 : 0
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "dynamodb:DescribeTable",
          "dynamodb:Scan",
          "rds:AddTagsToResource",
          "rds:CopyDBClusterSnapshot",
          "rds:CopyDBSnapshot",
          "rds:DescribeAccountAttributes",
          "rds:DescribeDBClusterSnapshots",
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances",
          "rds:DescribeDBSnapshots",
          "rds:DescribeDBSubnetGroups",
          "rds:ListTagsForResource",
          "redshift:CopyClusterSnapshot",
          "redshift:DescribeClusterSnapshots",
          "redshift:DescribeClusters",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "kms:CreateGrant"
        ],
        "Condition" : {
          "StringLike" : {
            "kms:ViaService" : "redshift.*.${data.aws_partition.current.dns_suffix}"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "kms:CreateGrant",
          "kms:ReEncrypt*"
        ],
        "Condition" : {
          "StringLike" : {
            "kms:ViaService" : "rds.*.${data.aws_partition.current.dns_suffix}"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "rds:CreateDBClusterSnapshot",
          "rds:CreateDBSnapshot"
        ],
        "Condition" : {
          "StringEquals" : {
            "rds:req-tag/wiz" : "auto-gen-snapshot"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "rds:DeleteDBClusterSnapshot",
          "rds:ModifyDBClusterSnapshotAttribute"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:${data.aws_partition.current.partition}:rds:*:*:cluster-snapshot:wiz-autogen-*"
      },
      {
        "Action" : [
          "rds:DeleteDBSnapshot",
          "rds:ModifyDBSnapshotAttribute"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:${data.aws_partition.current.partition}:rds:*:*:snapshot:wiz-autogen-*"
      },
      {
        "Action" : [
          "redshift:AuthorizeSnapshotAccess",
          "redshift:DeleteClusterSnapshot",
          "redshift:RevokeSnapshotAccess"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:${data.aws_partition.current.partition}:redshift:*:*:snapshot:*wiz-autogen-*"
      },
      {
        "Action" : [
          "redshift:CreateClusterSnapshot"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestTag/wiz" : "auto-gen-snapshot"
          }
        },
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "redshift:CreateTags"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:${data.aws_partition.current.partition}:redshift:*:*:snapshot:*/*"
      },
      {
        "Action" : [
          "s3:GetInventoryConfiguration",
          "s3:PutInventoryConfiguration"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ],
    "Version" : "2012-10-17"
  })
}

# Create EKS Scanning Managed Policy
resource "aws_iam_policy" "wiz_policy_eks" {
  name  = "WizEKSScanningPolicy"
  count = var.eks-scanning ? 1 : 0
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "eks:AssociateAccessPolicy"
        ],
        "Condition" : {
          "StringEquals" : {
            "eks:policyArn" : "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSAdminViewPolicy",
            "eks:principalArn" : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${local.wiz_role_name}"
          }
        },
        "Effect" : "Allow",
        "Resource" : [
          "*"
        ],
        "Sid" : "WizAssociateViewOnly"
      },
      {
        "Action" : [
          "eks:CreateAccessEntry"
        ],
        "Condition" : {
          "StringEquals" : {
            "eks:principalArn" : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${local.wiz_role_name}"
          }
        },
        "Effect" : "Allow",
        "Resource" : [
          "*"
        ],
        "Sid" : "WizCreateAccessEntry"
      },
      {
        "Action" : [
          "eks:DeleteAccessEntry"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:ResourceTag/CreatedBy" : "Wiz"
          }
        },
        "Effect" : "Allow",
        "Resource" : [
          "*"
        ],
        "Sid" : "WizDeleteAccessEntry"
      },
      {
        "Action" : [
          "eks:TagResource"
        ],
        "Condition" : {},
        "Effect" : "Allow",
        "Resource" : [
          "arn:${data.aws_partition.current.partition}:eks:*:*:access-entry/*/role/${data.aws_caller_identity.current.account_id}/${local.wiz_role_name}/*"
        ],
        "Sid" : "WizTagAccessEntry"
      }
    ],
    "Version" : "2012-10-17"
  })
}

# Create Wiz Defend Policy
resource "aws_iam_policy" "wiz_defend_policy" {
  name  = "WizDefendPolicy"
  count = (var.wiz-defend-rds-policy || var.wiz-defend-awslogs-policy || var.wiz-defend-s3-kms-policy) ? 1 : 0

  policy = jsonencode({
    Statement = local.defend_combined_statements,
    Version   = "2012-10-17"
  })
}

# Create Wiz TerraformScanningPolicy
resource "aws_iam_policy" "wiz_terraform_scanning_policy" {
  count = var.terraform-bucket-scanning ? 1 : 0
  name  = "WizTerraformScanningPolicy"
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:GetObjectTagging",
          "s3:ListBucket"
        ],
        "Effect" : "Allow",
        "Resource" : [
          "arn:${data.aws_partition.current.partition}:s3:::*cloudtrail*",
          "arn:${data.aws_partition.current.partition}:s3:::*terraform*",
          "arn:${data.aws_partition.current.partition}:s3:::*tf?state*",
          "arn:${data.aws_partition.current.partition}:s3:::*tfstate*",
          "arn:${data.aws_partition.current.partition}:s3:::amplify-*-deployment/*",
          "arn:${data.aws_partition.current.partition}:s3:::elasticbeanstalk-*"
        ],
        "Sid" : "WizTerraformBucketAccess"
      }
    ],
    "Version" : "2012-10-17"
  })
}

# Create Cloud Cost Policy
resource "aws_iam_policy" "wiz_cloud_cost_policy" {
  name  = "WizCloudCostPolicy"
  count = var.cloud-cost-scanning ? 1 : 0
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "compute-optimizer:GetAutoScalingGroupRecommendations",
          "compute-optimizer:GetEBSVolumeRecommendations",
          "compute-optimizer:GetEC2InstanceRecommendations",
          "compute-optimizer:GetECSServiceRecommendations",
          "compute-optimizer:GetEnrollmentStatus",
          "compute-optimizer:GetEnrollmentStatusesForOrganization",
          "compute-optimizer:GetIdleRecommendations",
          "compute-optimizer:GetLambdaFunctionRecommendations",
          "compute-optimizer:GetLicenseRecommendations",
          "compute-optimizer:GetRDSDatabaseRecommendations",
          "compute-optimizer:GetRecommendationSummaries"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "AllowWizToViewComputeOptimizerRecommendations"
      },
      {
        "Action" : [
          "trustedadvisor:ListChecks",
          "trustedadvisor:ListRecommendationResources",
          "trustedadvisor:ListRecommendations"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "AllowWizToCollectTrustedAdvisorRecommendations"
      }
    ],
    "Version" : "2012-10-17"
  })
}

locals {
  WizRDSLogsPolicy = [
    {
      "Action" : [
        "rds:DownloadCompleteDBLogFile",
        "rds:DownloadDBLogFilePortion"
      ],
      "Effect" : "Allow",
      "Resource" : "arn:${data.aws_partition.current.partition}:rds:*:*:db:*",
      "Sid" : "WizRDSLogsAccess"
    }
  ]
  WizS3AWSLogsPolicy = [
    {
      "Action" : [
        "s3:GetObject",
        "s3:GetObjectAttributes",
        "s3:GetObjectRetention"
      ],
      "Effect" : "Allow",
      "Resource" : [
        "arn:${data.aws_partition.current.partition}:s3:::*/*/AWSLogs/*",
        "arn:${data.aws_partition.current.partition}:s3:::*/AWSLogs/*"
      ],
      "Sid" : "WizS3AWSLogsGetObject"
    },
    {
      "Action" : [
        "s3:ListBucket"
      ],
      "Condition" : {
        "StringLike" : {
          "s3:prefix" : [
            "*/AWSLogs/*",
            "AWSLogs/*"
          ]
        }
      },
      "Effect" : "Allow",
      "Resource" : [
        "arn:${data.aws_partition.current.partition}:s3:::*"
      ],
      "Sid" : "WizS3AWSLogsListBucket"
    }
  ]
  WizS3KMSDecryptPolicy = [
    {
      "Action" : [
        "kms:Decrypt"
      ],
      "Condition" : {
        "StringEquals" : {
          "kms:ViaService" : "s3.${data.aws_partition.current.dns_suffix}"
        }
      },
      "Effect" : "Allow",
      "Resource" : "arn:${data.aws_partition.current.partition}:kms:*:*:key/*",
      "Sid" : "WizS3KMSDecrypt"
    }
  ]

  rds_statements     = [for stmt in local.WizRDSLogsPolicy : stmt if var.wiz-defend-rds-policy]
  awslogs_statements = [for stmt in local.WizS3AWSLogsPolicy : stmt if var.wiz-defend-awslogs-policy]
  s3kms_statements   = [for stmt in local.WizS3KMSDecryptPolicy : stmt if var.wiz-defend-s3-kms-policy]

  defend_combined_statements = concat(local.rds_statements, local.awslogs_statements, local.s3kms_statements)
}
