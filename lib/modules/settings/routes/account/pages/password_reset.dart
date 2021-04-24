import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/settings.dart';

class SettingsAccountPasswordResetRouter extends SettingsPageRouter {
  SettingsAccountPasswordResetRouter()
      : super('/settings/account/passwordreset');

  @override
  _Widget widget() => _Widget();

  @override
  void defineRoute(FluroRouter router) {
    super.noParameterRouteDefinition(router);
  }
}

class _Widget extends StatefulWidget {
  @override
  State<_Widget> createState() => _State();
}

class _State extends State<_Widget> with LunaScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LunaScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
      bottomNavigationBar: _bottomActionBar(),
    );
  }

  Widget _appBar() {
    return LunaAppBar(
      title: 'Password Reset',
      scrollControllers: [scrollController],
    );
  }

  Widget _bottomActionBar() {
    return LunaBottomActionBar(
      actions: [
        LunaButton.text(
          text: 'Reset Password',
          icon: Icons.vpn_key_rounded,
          onTap: _resetPassword,
        ),
      ],
    );
  }

  Widget _body() {
    return LunaListView(
      controller: scrollController,
      children: [
        AutofillGroup(
          child: LunaCard(
            context: context,
            child: Column(
              children: [
                LunaTextInputBar(
                  controller: _emailController,
                  isFormField: true,
                  margin: EdgeInsets.all(12.0),
                  labelIcon: Icons.person,
                  labelText: 'Email',
                  action: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: [AutofillHints.username, AutofillHints.email],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _resetPassword() async {
    if (_validateEmailAddress()) {
      LunaFirebaseAuth()
          .resetPassword(_emailController.text)
          .then((_) => showLunaSuccessSnackBar(
                title: 'Email Sent',
                message: 'An email to reset your password has been sent!',
              ))
          .catchError((error, stack) {
        LunaLogger().error(
            'Failed to reset password: ${_emailController.text}', error, stack);
        showLunaErrorSnackBar(title: 'Failed to Reset Password', error: error);
      });
    }
  }

  bool _validateEmailAddress({bool showSnackBarOnFailure = true}) {
    const _regex = r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)";
    if (!RegExp(_regex).hasMatch(_emailController.text)) {
      if (showSnackBarOnFailure) {
        showLunaErrorSnackBar(
          title: 'Invalid Email',
          message: 'The email address is invalid',
        );
      }
      return false;
    }
    return true;
  }
}
