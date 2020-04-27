# fargate-ssm

Fargateのコンテナ内でシェルを起動するためのコンテナイメージ。

コンテナの起動時にアクティベーションの作成とインスタンスの登録を行う。

## 参考リンク

- [[AWS ECS]Fargateのcontainerにシェルで入りたい(sshd無しで！)](https://qiita.com/pocari/items/3f3d77c80893f9f1e132)
- [FargateのコンテナでOSコマンドやsshで入りたい!! それssm-agentで解決できます](https://qiita.com/ryurock/items/fa18b25b1b38c9a0f113)
- [Support fargate/SSM Sessions #138](https://github.com/aws/amazon-ssm-agent/issues/138)
- [Step 6: Install SSM Agent for a hybrid environment (Linux)](https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/sysman-install-managed-linux.html)

## サービスロールの作成

`AmazonEC2RunCommandRoleForManagedInstances`が存在しない場合は作成する。マネジメントコンソールでアクティベーションを作成するのが簡単。

自分でサービスロールを作成する場合は以下のようにする。

ロールを作成する。

```sh
cat <<EOF > SSMService-Trust.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ssm.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
aws iam create-role \
    --role-name SSMServiceRole \
    --assume-role-policy-document file://SSMService-Trust.json
```

AWS管理ポリシーをアタッチする。

```sh
aws iam attach-role-policy \
    --role-name SSMServiceRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
```

## タスクロールの作成

ロールを作成する。

```sh
cat <<EOF > ecs-tasks-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
aws iam create-role \
    --role-name MyFargateSSMStandaloneTaskRole \
    --assume-role-policy-document file://ecs-tasks-trust-policy.json
```

管理ポリシーを作成する。PassRoleが必要。

```sh
ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
cat <<EOF > ecs-tasks-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "arn:aws:iam::${ACCOUNT_ID}:role/SSMServiceRole"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:CreateActivation"
      ],
      "Resource": "*"
    }
  ]
}
EOF
aws iam create-policy \
    --policy-name MyFargateSSMStandaloneTaskPolicy \
    --policy-document file://ecs-tasks-policy.json
PolicyArn=$(aws iam list-policies | jq -r '.Policies[] | select( .PolicyName | test("MyFargateSSMStandaloneTaskPolicy") ) | .Arn')
```

ロールに管理ポリシーをアタッチする。

```sh
aws iam attach-role-policy \
    --role-name MyFargateSSMStandaloneTaskRole \
    --policy-arn ${PolicyArn}
RoleArn=$(aws iam list-roles | jq -r '.Roles[] | select( .RoleName | test("MyFargateSSMStandaloneTaskRole") ) | .Arn')
```

## タスク定義の作成

タスク定義のjsonを作成する。

```sh
cat <<EOF > task-definition.json
{
  "family": "fargate-ssm-standalone",
  "taskRoleArn": "${RoleArn}",
  "executionRoleArn": "ecsTaskExecutionRole",
  "networkMode": "awsvpc",
  "containerDefinitions": [
    {
      "name": "fargate-ssm-standalone",
      "image": "${repo}",
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/fargate-ssm-standalone",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ],
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024"
}
EOF
```

タスク定義を登録する。

```sh
aws ecs register-task-definition --cli-input-json file://task-definition.json
```

ロググループを作成する。

```sh
aws logs create-log-group --log-group-name "/ecs/fargate-ssm-standalone"
```
