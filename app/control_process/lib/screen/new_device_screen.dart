import 'package:flutter/material.dart';

class NewDeviceScreen extends StatefulWidget {
  const NewDeviceScreen({super.key});

  @override
  State<NewDeviceScreen> createState() => _NewDeviceScreenState();
}

class _NewDeviceScreenState extends State<NewDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
              child: SizedBox(
                width: 600,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 2 / 3,
                                child: Text(
                                  "Adicionar aparelho na minha lista",
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 64,
                                child: TextFormField(
                                  controller: _textEditingController,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  strutStyle: StrutStyle.fromTextStyle(
                                    Theme.of(context).textTheme.bodyMedium!,
                                  ),
                                  keyboardType: TextInputType.visiblePassword,
                                  autocorrect: false,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (text) {},
                                  decoration: const InputDecoration(
                                    helperText:
                                        "Digite o código de seu aparelho.",
                                    // label: const Text(
                                    //   "Senha: ",
                                    // ),
                                    labelText: "Código:",
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 32,
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context, _textEditingController.text);
                                },
                                child: const Text("Salvar"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
