// Setup script per kicker (menu applicazioni) SparkleOS
var kickerSetup = {
    configure: function() {
        // Configura il menu kicker con stile SparkleOS
        try {
            var kicker = workspace.desktops[0].addWidget("org.kde.plasma.kicker");
            if (kicker) {
                kicker.currentConfigGroup = ["General"];
                kicker.writeConfig("icon", "start-here-kde");
                kicker.writeConfig("useCustomButtonImage", "false");
            }
        } catch (e) {
            console.log("Errore configurazione kicker: " + e);
        }
    }
};
