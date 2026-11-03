set(mo_files)

qml_module(caelestia-i18n
    URI Caelestia.I18n
    INCLUDE_PREFIX i18n
    SOURCES
        translator.cpp
        pluralrules.cpp
    QML_SINGLETONS
        Tr.qml
        Units.qml
    RESOURCES
        ${mo_files}
    LIBRARIES
        caelestia-util
        caelestia-config
    DEPENDENCIES
        Caelestia
        Caelestia.Config
)
