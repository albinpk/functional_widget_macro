
// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:macros/macros.dart';

final _material = Uri.parse('package:flutter/material.dart');
final _core = Uri.parse('dart:core');

macro //
class Fun implements FunctionTypesMacro {
  const Fun();

  @override
  Future<void> buildTypesForFunction(
    FunctionDeclaration function,
    TypeBuilder builder,
  ) async {
    try {
      final returnIdentifier =
          (function.returnType as NamedTypeAnnotation).identifier;
      if (returnIdentifier.name != 'Widget') {
        throw Exception();
      }
    } catch (e) {
      return builder.report(
        Diagnostic(
          DiagnosticMessage('The return type should be "Widget"'),
          Severity.error,
        ),
      );
    }

    final functionRealName = function.identifier.name;

    if (functionRealName[0] != '_') {
      return builder.report(
        Diagnostic(
          DiagnosticMessage('The function should be private'),
          Severity.error,
        ),
      );
    }

    final functionName = functionRealName.substring(1);
    final widgetName = _getWidgetName(functionName);

    // identifiers
    final widget = await builder.resolveIdentifier(_material, 'Widget');
    final key = await builder.resolveIdentifier(_material, 'Key');
    final statelessWidget =
        await builder.resolveIdentifier(_material, 'StatelessWidget');
    final buildContext =
        await builder.resolveIdentifier(_material, 'BuildContext');
    final override = await builder.resolveIdentifier(_core, 'override');

    // parameters
    final positionalParams = function.positionalParameters.toList();
    final namedParams = function.namedParameters.toList();
    final allParams = [...positionalParams, ...namedParams];
    final contextParam = allParams.where((p) => p.isContext).firstOrNull;
    positionalParams.removeWhere((p) => p.isContext);
    namedParams.removeWhere((p) => p.isContext);
    // parameters without context
    final params = allParams.where((p) => !p.isContext).toList();

    final hasContext = contextParam != null;
    

    builder.declareType(
      widgetName,
      DeclarationCode.fromParts([
        "import 'dart:core';\n\n",
        'class $widgetName extends ',
        statelessWidget,
        ' {\n'
            '  const $widgetName(',

        ...positionalParams.where((p) => !p.isContext).map((param) {
          return DeclarationCode.fromParts([
            '\n    this.',
            param.identifier.name,
            ',',
          ]);
        }),

          if (positionalParams.isNotEmpty) ' ',
        '{\n    ',
        'super.key,\n',


        if (namedParams.isNotEmpty) ...[
          ...namedParams.where((p) => !p.isContext).map((param) {
            return DeclarationCode.fromParts([
              '    ${param.isRequired ? 'required ' : ''}this.',
              param.identifier.name,
              ',\n',
            ]);
          }),
        ],


        '  });\n\n',

        // fields
        ...params.where((p) => !p.isContext).map((param) {
          return DeclarationCode.fromParts([
            '  final ',
            (param.type as NamedTypeAnnotation).identifier.name,
            if (param.type.isNullable) '?',
            ' ',
            param.identifier.name,
            ';\n',
          ]);
        }),

        // build method
        '\n  @',
        override,
        '\n  ',
        widget,
        ' build(',
        buildContext,
        ' context) {\n'
            '    return _$functionName(',

        ...allParams.map((param) {
          return DeclarationCode.fromParts([
            '\n      ',
            if (param.isNamed) '${param.identifier.name}: ',
            param.isContext ? 'context' : param.identifier.name,
            ',',
          ]);
        }),

        '\n    ',

        ');\n',
        '  }\n',
        '}',
      ]),
    );
  }

  String _getWidgetName(String functionName) {
    return functionName[0].toUpperCase() + functionName.substring(1);
  }

  void _print(TypeBuilder builder, Object? message) {
    builder.report(
      Diagnostic(
        DiagnosticMessage(message.toString()),
        Severity.info,
      ),
    );
  }
}

extension on FormalParameterDeclaration {
  bool get isContext {
    return (type as NamedTypeAnnotation).identifier.name == 'BuildContext';
  }
}
