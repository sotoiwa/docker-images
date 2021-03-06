# fargate-ssm

Fargateのコンテナ内でシェルを起動するためのコンテナイメージ。

あらかじめActivation IDを作成してコンテナの起動時に環境変数から渡す。

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

## アクティベーションの作成

アクティベーションを作成し、IDとコードを保管しておく。

```sh
aws ssm create-activation \
  --default-instance-name "DockerSSM" \
  --iam-role "SSMServiceRole" \
  --registration-limit 1 | tee activation.json
```

## タスク定義の作成

タスク定義のjsonを作成する。環境変数にActivation IDとActivation Codeを入れる。

```sh
activation_id=$(cat activation.json | jq -r '.ActivationId')
activation_code=$(cat activation.json | jq -r '.ActivationCode')
cat <<EOF > task-definition.json
{
  "family": "fargate-ssm",
  "executionRoleArn": "ecsTaskExecutionRole",
  "networkMode": "awsvpc",
  "containerDefinitions": [
    {
      "name": "fargate-ssm",
      "image": "${repo}",
      "essential": true,
      "environment": [
        {
          "name": "ACTIVATION_ID",
          "value": "${activation_id}"
        },
        {
          "name": "ACTIVATION_CODE",
          "value": "${activation_code}"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/fargate-ssm",
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
aws logs create-log-group --log-group-name "/ecs/fargate-ssm"
```
