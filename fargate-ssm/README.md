## 参考リンク

- [[AWS ECS]Fargateのcontainerにシェルで入りたい(sshd無しで！)](https://qiita.com/pocari/items/3f3d77c80893f9f1e132)
- [FargateのコンテナでOSコマンドやsshで入りたい!! それssm-agentで解決できます](https://qiita.com/ryurock/items/fa18b25b1b38c9a0f113)
- [Support fargate/SSM Sessions #138](https://github.com/aws/amazon-ssm-agent/issues/138)

## エージェントのインストール

- [Step 6: Install SSM Agent for a hybrid environment (Linux)](https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/sysman-install-managed-linux.html)

## イメージのビルド

## タスクロールの作成

信頼ポリシーのjsonを作成する。

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
```

ロールを作成する。

```sh
aws iam create-role --role-name MyFargateSSMTaskRole --assume-role-policy-document file://ecs-tasks-trust-policy.json
```

ロールに管理ポリシーをアタッチする。

```sh
put-role-policy	attach-role-policy

