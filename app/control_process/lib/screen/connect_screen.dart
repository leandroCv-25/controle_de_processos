import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/connect_controller.dart';
import '../provider/connection_provider.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<ConnectionProvider, ConnectController>(
      create: (context) {
        return ConnectController();
      },
      update: (BuildContext context, ConnectionProvider connectionProvider,
          ConnectController? connectController) {
        if (connectController != null) {
          return connectController..update(connectionProvider);
        } else {
          return ConnectController()..update(connectionProvider);
        }
      },
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Conectar"),
          ),
          body: Stack(
            alignment: Alignment.topCenter,
            fit: StackFit.expand,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.asset("assets/logo.png"),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Card(
                          margin: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: min(600, MediaQuery.of(context).size.width),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Consumer<ConnectController>(
                                builder: (context, connectController, header) {
                                  if (connectController.error != null ||
                                      connectController.connectionName ==
                                          null) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        header!,
                                        const Icon(Icons.error),
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            text: "Erro: ",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                            children: [
                                              TextSpan(
                                                text: connectController.error,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      header!,
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                64,
                                        child: RichText(
                                          textAlign: TextAlign.start,
                                          text: TextSpan(
                                            text: "Rede: ",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                            children: [
                                              TextSpan(
                                                text: connectController
                                                    .connectionName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                64,
                                        child: TextFormField(
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          strutStyle: StrutStyle.fromTextStyle(
                                            Theme.of(context)
                                                .textTheme
                                                .bodyMedium!,
                                          ),
                                          initialValue: connectController
                                              .connectionPassword,
                                          onChanged: (value) =>
                                              connectController
                                                  .connectionPassword = value,
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          validator: (value) => value == null ||
                                                  value.length < 8
                                              ? "Senha deve conter pelo menos 8 Caracteres"
                                              : null,
                                          autocorrect: false,
                                          textInputAction: TextInputAction.done,
                                          onFieldSubmitted: connectController
                                                      .loading ||
                                                  connectController
                                                      .connectionPasswordError ||
                                                  connectController.done
                                              ? null
                                              : (_) {
                                                  connectController
                                                      .sendConnection();
                                                },
                                          maxLength: 63,
                                          obscureText:
                                              connectController.obscurePassword,
                                          decoration: InputDecoration(
                                            helperText:
                                                "Digite a senha da sua rede.",
                                            // label: const Text(
                                            //   "Senha: ",
                                            // ),
                                            labelText: "Senha:",

                                            suffixIcon: IconButton(
                                              onPressed: connectController
                                                  .obscurePasswordToogle,
                                              icon: connectController
                                                      .obscurePassword
                                                  ? const Icon(Icons.visibility)
                                                  : const Icon(
                                                      Icons.visibility_off),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 32,
                                      ),
                                      Visibility(
                                        visible: connectController.loading,
                                        child: const Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: SizedBox(
                                            height: 32,
                                            width: 32,
                                            child: CircularProgressIndicator(
                                              semanticsLabel: "Carregando",
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Visibility(
                                      //   visible: !connectController.loading,
                                      //   child: TextButton(
                                      //     onPressed: () {},
                                      //     child: const Text("Manual"),
                                      //   ),
                                      // ),
                                      FilledButton.icon(
                                        onPressed: connectController.loading ||
                                                connectController.done
                                            ? null
                                            : connectController
                                                    .connectionPasswordError
                                                ? () {
                                                    _formKey.currentState!
                                                        .validate();
                                                  }
                                                : () {
                                                    connectController
                                                        .sendConnection();
                                                  },
                                        label: connectController.loading
                                            ? const Text("Carregando")
                                            : connectController.done
                                                ? const Text("Pronto")
                                                : const Text("Conectar"),
                                        icon: connectController.loading
                                            ? const Icon(
                                                Icons.timelapse,
                                              )
                                            : connectController.done
                                                ? const Icon(
                                                    Icons.done,
                                                  )
                                                : const Icon(
                                                    Icons.contactless_rounded,
                                                  ),
                                      ),
                                    ],
                                  );
                                },
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 2 / 3,
                                  child: Text(
                                    "Conectar aparelho a rede",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
