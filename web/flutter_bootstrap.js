{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    var host = document.getElementById("flutter-host");
    var appRunner = await engineInitializer.initializeEngine({
      hostElement: host,
    });
    await appRunner.runApp();
  },
});
