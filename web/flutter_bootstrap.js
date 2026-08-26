{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    var host = document.getElementById("flutter-host");
    // CanvasKit required for stable BackdropFilter blur on Safari / PWA.
    var appRunner = await engineInitializer.initializeEngine({
      hostElement: host,
      renderer: "canvaskit",
    });
    await appRunner.runApp();
  },
});
