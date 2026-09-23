import 'package:flutter/material.dart';

class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required Widget page,
  }) : super(
          pageBuilder: (
            context,
            animation,
            secondaryAnimation,
          ) {
            return page;
          },
          transitionDuration: const Duration(
            milliseconds: 280,
          ),
          reverseTransitionDuration: const Duration(
            milliseconds: 220,
          ),
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            const begin = Offset(
              0.08,
              0,
            );

            const end = Offset.zero;

            final slideAnimation = Tween<Offset>(
              begin: begin,
              end: end,
            ).chain(
              CurveTween(
                curve: Curves.easeOutCubic,
              ),
            );

            final fadeAnimation = Tween<double>(
              begin: 0,
              end: 1,
            ).chain(
              CurveTween(
                curve: Curves.easeOut,
              ),
            );

            return FadeTransition(
              opacity: animation.drive(
                fadeAnimation,
              ),
              child: SlideTransition(
                position: animation.drive(
                  slideAnimation,
                ),
                child: child,
              ),
            );
          },
        );
}

