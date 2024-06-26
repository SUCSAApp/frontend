import 'package:flutter/material.dart';

class TermsofUse extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SelectableText('使用条款', style: const TextStyle(color: Colors.white)), backgroundColor: const Color.fromRGBO(29, 32, 136, 1.0),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: SelectableText(
         '1. 使用条款'
            '\n\n1.1 使用本应用即表示您同意遵守以下条款。若您不同意这些条款，请停止使用本软件。'
        '\n\n1.2 您应自行承担使用本软件的风险。本软件仅供个人非商业用途使用'
            '\n\n2. 用户行为'
            '\n\n2.1 您应遵守澳大利亚法律法规，并承担因违反法律法规而产生的一切责任。'
        '\n\n2.2 您不得利用本软件从事违法、侵权或损害他人合法权益的行为，包括但不限于传播色情、暴力、恐怖主义等信息，侵犯他人知识产权、隐私权等行为。'
        '\n\n3. 知识产权'
            '\n\n3.1 本软件及其相关内容（包括但不限于文字、图片、音频、视频等）的知识产权归软件开发者所有，受法律保护。'
        '\n\n3.2 未经软件开发者授权，您不得以任何形式复制、修改、传播、展示、出租或出售本软件及其相关内容。'
            '\n\n4. 免责声明'
        '\n\n4.2 您理解并同意，使用本软件所产生的任何风险和损失均由您自行承担，软件开发者不承担任何责任。'
            '\n\n5. 隐私政策'
            '\n\n5.1. 本应用可能会收集并使用您的个人信息，包括但不限于您的个人信息、设备信息、位置信息、使用习惯等。我们收集这些信息的目的是为了改善和个性化您的使用体验，并且我们会采取适当的安全措施来保护您的信息。'
        '\n\n5.2. 本应用不对您因使用本程序而导致的任何个人信息泄露、丢失、被盗用或被篡改等问题承担责任。您应自行承担使用本应用所产生的风险，并且理解使用互联网服务存在一定的风险。'
        '\n\n5.3. 本应用可能包含指向第三方网站或服务的链接。您应审慎阅读并理解这些第三方网站或服务的隐私政策，我们不对其内容和安全性负责。'
            '\n\n6. 修改和解释权'
            '\n\n6.1 软件开发者保留随时修改本用户须知条款的权利，修改后的条款将通过本软甲或微信公众号推文方式通知您。'
        '\n\n6.2 本用户须知条款的解释权归软件开发者所有。'
            '\n\n7. 联系我们'
        '\n\n如果您对本用户须知条款或软件使用有任何疑问或意见，请通过官方微信小助手：ilovesydney 与我们联系。'
            '\n\n 悉尼大学中国学生学者联合会',
            style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}


