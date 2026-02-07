import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/common/app_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo/图标
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.favorite,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              // 标题
              Text(
                '脉冲',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '生活节律协同助手',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // 描述
              Text(
                '一个以AI为原生驱动的智能日程管理工具，'
                '帮助您和亲密伙伴更好地协调生活节奏。',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // 开始按钮
              AppButton(
                text: '开始使用',
                isFullWidth: true,
                onPressed: () => context.go('/timeline'),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: '登录 / 注册',
                type: AppButtonType.secondary,
                isFullWidth: true,
                onPressed: () => context.push('/login'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // 显示关于对话框
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('关于脉冲'),
                      content: const Text(
                        '脉冲是一款AI原生的生活节律协同助手，'
                        '通过智能时间线和自然语言交互，'
                        '让日程管理变得前所未有的简单和有趣。',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('关闭'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('了解更多'),
              ),
              const SizedBox(height: 24),
              // 版本信息
              Text(
                'v0.1.0',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
