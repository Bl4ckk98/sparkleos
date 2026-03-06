var plasma = getApiVersion(1);

var layout = {
    "panels": [
        {
            "alignment": "center",
            "applets": [
                {
                    "config": {
                        "/": {
                            "PreloadWeight": "100",
                            "popupHeight": "495",
                            "popupWidth": "657"
                        },
                        "/ConfigDialog": {
                            "DialogHeight": "540",
                            "DialogWidth": "720"
                        },
                        "/General": {
                            "applicationsDisplay": "0",
                            "favoritesPortedToKAstats": "true",
                            "icon": "start-here-kde",
                            "systemFavorites": "suspend\\,hibernate\\,reboot\\,shutdown"
                        },
                        "/Shortcuts": {
                            "global": "Alt+F1"
                        }
                    },
                    "plugin": "org.kde.plasma.kickoff"
                },
                {
                    "config": {
                        "/ConfigDialog": {
                            "DialogHeight": "480",
                            "DialogWidth": "796"
                        },
                        "/General": {
                            "containmentType": "Plasma",
                            "lengthFirstMargin": "6",
                            "lengthLastMargin": "4",
                            "lengthMarginsLock": "false",
                            "showIcon": "false"
                        }
                    },
                    "plugin": "org.kde.plasma.appmenu"
                },
                {
                    "config": {
                    },
                    "plugin": "org.kde.plasma.panelspacer"
                },
                {
                    "config": {
                        "/": {
                            "PreloadWeight": "100",
                            "popupHeight": "450",
                            "popupWidth": "396"
                        },
                        "/Appearance": {
                            "customSpacing": "1.7171717171717171",
                            "enabledCalendarPlugins": "/usr/lib/qt6/plugins/plasmacalendarplugins/holidaysevents.so",
                            "fixedFont": "true",
                            "fontFamily": "SFNS Display",
                            "fontSize": "15"
                        },
                        "/ConfigDialog": {
                            "DialogHeight": "510",
                            "DialogWidth": "680"
                        }
                    },
                    "plugin": "org.kde.plasma.digitalclock"
                },
                {
                    "config": {
                    },
                    "plugin": "org.kde.plasma.panelspacer"
                },
                {
                    "config": {
                        "/ConfigDialog": {
                            "DialogHeight": "480",
                            "DialogWidth": "640"
                        }
                    },
                    "plugin": "org.kde.plasma.marginsseparator"
                },
                {
                    "config": {
                        "/": {
                            "PreloadWeight": "100"
                        }
                    },
                    "plugin": "org.kde.plasma.systemtray"
                }
            ],
            "config": {
                "/": {
                    "formfactor": "2",
                    "immutability": "1",
                    "lastScreen": "0",
                    "wallpaperplugin": "org.kde.image"
                },
                "/ConfigDialog": {
                    "DialogHeight": "78",
                    "DialogWidth": "1920"
                }
            },
            "height": 40,
            "hiding": "normal",
            "location": "top",
            "floating": 0,
            "maximumLength": 120,
            "minimumLength": 120,
            "offset": 0
        },
        {
            "alignment": "center",
            "applets": [
                {
                    "config": {
                        "/General": {
                            "launchers": "applications:org.kde.dolphin.desktop,applications:org.kde.konsole.desktop,applications:firefox.desktop"
                        }
                    },
                    "plugin": "org.kde.plasma.icontasks"
                }
            ],
            "config": {
                "/": {
                    "formfactor": "2",
                    "immutability": "1",
                    "lastScreen": "0",
                    "wallpaperplugin": "org.kde.image"
                },
                "/ConfigDialog": {
                    "DialogHeight": "78",
                    "DialogWidth": "1920"
                }
            },
            "height": 3.25,
            "hiding": "windowscover",
            "location": "bottom",
            "floating": 1,
            "lengthMode": "fit",
            "offset": 0
        }
    ],
    "serializationFormatVersion": "1"
}
    ;

plasma.loadSerializedLayout(layout);
