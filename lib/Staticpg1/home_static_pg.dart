import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';




class HomeStaticPage1 extends StatefulWidget {
  const HomeStaticPage1({super.key});

  @override
  State<HomeStaticPage1> createState() => _HomeStaticPage1State();
}

class Organization {
  final String name;
  final String logoUrl;
  final String description;
  final String link;

  Organization({
    required this.name,
    required this.logoUrl,
    required this.description,
    required this.link,
  });
}
class _HomeStaticPage1State extends State<HomeStaticPage1> {
  final List<Organization> organizations = [
    Organization(
      name: '中国驻悉尼总领馆',
      logoUrl: 'lib/assets/官方合作/中国驻悉尼总领事馆.png',
      description: '中国于1979年3月19日在悉尼设立总领事馆，领区为新南威尔士州。 新州位于澳大利亚东南部，是澳历史最悠久、人口最多、经济最发达的州。 新州在发展对华关系方面长期走在澳各州区前列。 近年来，中国连续多年保持新州最大贸易伙伴地位， 新州吸引了近半数中国对澳投资、约六成中国游客和超过三成中国留学生。',
      link: 'http://sydney.china-consulate.gov.cn/',
    ),
    Organization(
      name: 'SRC',
      logoUrl: 'lib/assets/官方合作/SRC logo 1.png',
      description: '悉尼大学本科学生代表会（Students’Representative Council）自1929年以来由学生为学生管理， 是悉尼大学本科生的最高代表机构，以维护和促进悉尼大学学生的利益为宗旨。 SRC有着为学生权利而奋斗的悠久历史。SRC主张自由、公平和资助的教育， 普遍的学生会主义和一个没有歧视和压迫的社会。SRC的工作人员提供必要的服务， 如SRC个案工作者帮助（学术、Centrelink和租房咨询），以及免费法律服务。 这些服务是为悉尼大学的本科生免费提供的。SRC还设出版刊物Honi Soit，这是全澳唯一的学生周报。',
      link: 'https://srcusyd.net.au/',
    ),
    Organization(
      name: 'SUPRA',
      logoUrl: 'lib/assets/官方合作/SUPRA logo 1.png',
      description: 'SUPRA是悉尼大学的研究生协会。研会由学生代表及专业工作人员组成， 旨在维护学生权益，代表学生立场，支持学生发展，服务悉大全体硕博学生。 SUPRA悉大研会提供免费、专业且保密的一对一个案咨询服务。 经验丰富，通晓悉大政策和学生事务的个案咨询师， 将协助学生应对学业和生活中遇到的各类问题和困难。 SUPRA还聘请了资深法律援助律师，为大家提供法律事务咨询、法庭代理和转介服务。 与此同时，研会还致力于构建多元包容的硕博学生社群，组织和筹办丰富多彩的校园活动。',
      link: 'https://supra.net.au/',
    ),
    Organization(
      name: '悉尼大学中国中心',
      logoUrl: 'lib/assets/官方合作/the-university-of-sydney-vector-logo 1.png',
      description: '悉尼大学中国中心（以下简称“中国中心”）是悉尼大学在澳洲本土之外设立的第一个教育和研究中心。 中国中心位于苏州工业园区的独墅湖科教创新区， 是一个跨学科和跨文化的研究和教育孵化器， 旨在促进和加强澳大利亚与中国研究人员、学者、学生及校友之间的交流。 依托悉尼大学世界一流的研究资源和基础设施，中国中心致力于促进中澳之间的研究创新、 学术交流和产业合作。通过在健康、环境与可持续发展，以及科技和商业等方面的努力， 中心将积极为中国教育、卓越研究和知识创造的可持续发展做出贡献。',
      link: 'https://sydneyuniversity.cn/',
    ),
    Organization(
      name: 'USU',
      logoUrl: 'lib/assets/官方合作/university-of-sydney-union 1.png',
      description: '悉尼大学学生工会 (University of Sydney Union) 成立于1874年， 是一个为尊重学生的多元讨论而设立的社团，是澳大利亚最大的、独立的学生组织。 USU以非盈利为荣，提供广泛的服务、活动、项目、设施和机会，帮助每个学生充分利用他们在大学的时间。 除了支持200多个学生社团外，USU还负责在讲座和考试之外提供许多有趣的活动项目， 包括大型节日、派对、演出和大量以学生为中心的活动， 以及学生志愿者计划、学生领导和带薪工作机会。 USU还通过校内的咖啡馆、商店和官网提供餐饮和正版学校周边商品。',
      link: 'https://usu.edu.au/',
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 32, 136, 1.0),
        title: const Text('合作官方组织', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,)),
      ),
      body: ListView.builder(
        itemCount: organizations.length,
        itemBuilder: (context, index) {
          return _buildOrganizationCard(context, organizations[index]);
        },
      ),
    );
  }

  Widget _buildOrganizationCard(BuildContext context, Organization organization) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            organization.logoUrl,
            height: 100.0,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          ListTile(
            title: Text(organization.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),),

          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              organization.description,
              style: TextStyle(fontSize: 12.0),
              // Initially, you might want to show a summary or a shorter version of the description
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _launchURL(organization.link);
              },
              child: const Text('访问官网', style: TextStyle(color: Color.fromRGBO(29,32,136,1.0), fontSize: 20, fontWeight: FontWeight.bold,)),
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('无法打开链接: $url'),
        ),
      );
    }
  }
}
