import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_center/deb/deb.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packagekit/packagekit.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_test/yaru_test.dart';

import 'test_utils.dart';

void main() {
  const baseline = bool.fromEnvironment('SCREENSHOT_BASELINE');
  tearDown(resetAllServices);
  for (final installedVersion in baseline ? ['0.9'] : ['0.9', '1.0', '1.1']) {
    testWidgets('capture local 1.0 with installed $installedVersion', (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      createMockPackageKitService(
        packageDetails: PackageKitPackageDetails(
          packageId: const PackageKitPackageId(name: 'testdeb', version: '1.0'),
          summary: 'Local Debian package regression fixture',
          description: 'A local package used to demonstrate the installation action for PR #2217.',
          license: 'GPL-3.0',
          size: 1024 * 1024,
          url: 'https://example.org',
        ),
        packageInfo: PackageKitPackageInfo(
          info: PackageKitInfo.installed,
          packageId: PackageKitPackageId(name: 'testdeb', version: installedVersion),
          summary: 'Local Debian package regression fixture',
        ),
      );
      await tester.pumpApp((_) => const SizedBox());
      tester.view.physicalSize = const Size(1000, 720);
      const boundaryKey = ValueKey('screenshot');
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: MaterialApp(
            theme: yaruLight.copyWith(textTheme: yaruLight.textTheme.apply(fontFamily: 'UbuntuRegular')),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: localizationsDelegates,
            home: const Scaffold(
              body: ProviderScope(
                child: LocalDebPage(path: '/tmp/testdeb_1.0_all.deb'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final installed = baseline || installedVersion == '1.0';
      expect(
        find.button(installed ? tester.l10n.snapActionInstalledLabel : tester.l10n.snapActionInstallLabel),
        installed ? isDisabled : isEnabled,
      );
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(boundaryKey));
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final label = baseline ? 'before' : 'after';
        final path = '/workspaces/OSC/artifacts/app-center-pr-2217/$label-local-1.0-installed-$installedVersion.png';
        await File(path).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      if (!baseline && installedVersion == '0.9') {
        await tester.tapButton(tester.l10n.snapActionInstallLabel);
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('/workspaces/OSC/artifacts/app-center-pr-2217/after-confirmation-dialog.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    });
  }
}
