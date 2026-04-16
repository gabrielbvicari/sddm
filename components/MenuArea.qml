import QtQuick
import QtQuick.Controls

Item {
    id: menuArea

    property var createdObjects: []

    function calculatePopupPos(direction, align, popup, button) {
        var popupMargin = Config.menuAreaPopupsMargin;
        var x = 0, y = 0;

        if (direction === "up") {
            y = -popup.height - popupMargin;

            if (align === "start")
                x = 0;
            else if (align === "end")
                x = -popup.width + button.width;
            else
                x = (button.width - popup.width) / 2;
        } else if (direction === "down") {
            y = button.height + popupMargin;

            if (align === "start")
                x = 0;
            else if (align === "end")
                x = -popup.width + button.width;
            else
                x = (button.width - popup.width) / 2;
        } else if (direction === "left") {
            x = -popup.width - popupMargin;

            if (align === "start")
                y = 0;
            else if (align === "end")
                y = -popup.height + button.height;
            else
                y = (button.height - popup.height) / 2;
        } else {
            x = button.width + popupMargin;

            if (align === "start")
                y = 0;
            else if (align === "end")
                y = -popup.height + button.height;
            else
                y = (button.height - popup.height) / 2;
        }

        return [x, y];
    }

    anchors.fill: parent

    Component.onCompleted: {
        var menus = Config.sortMenuButtons();

        for (var i = 0; i < menus.length; i++) {
            var pos;

            switch (menus[i].position) {
            case "top-left":
                pos = topLeftButtons;
                break;
            case "top-center":
                pos = topCenterButtons;
                break;
            case "top-right":
                pos = topRightButtons;
                break;
            case "center-left":
                pos = centerLeftButtons;
                break;
            case "center-right":
                pos = centerRightButtons;
                break;
            case "bottom-left":
                pos = bottomLeftButtons;
                break;
            case "bottom-center":
                pos = bottomCenterButtons;
                break;
            case "bottom-right":
                pos = bottomRightButtons;
                break;
            }

            var createdObject;

            if (menus[i].name === "session")
                createdObject = sessionMenuComponent.createObject(pos, {
            });
            else if (menus[i].name === "layout")
                createdObject = layoutMenuComponent.createObject(pos, {
            });
            else if (menus[i].name === "power")
                createdObject = powerMenuComponent.createObject(pos, {
            });
            if (createdObject)
                createdObjects.push(createdObject);
        }
    }

    Component.onDestruction: {
        for (var i = 0; i < createdObjects.length; i++) {
            if (createdObjects[i])
                createdObjects[i].destroy();

        }

        createdObjects = [];
    }

    Component {
        id: sessionMenuComponent

        IconButton {
            id: sessionButton

            property bool showLabel: Config.sessionDisplaySessionName

            preferredWidth: showLabel ? (Config.sessionButtonWidth === -1 ? undefined : Config.sessionButtonWidth) : Config.menuAreaButtonsSize
            height: Config.menuAreaButtonsSize * Config.generalScale
            iconSize: Config.sessionIconSize
            fontSize: Config.sessionFontSize
            enabled: loginScreen.state === "normal" || popup.visible
            active: popup.visible
            contentColor: Config.sessionContentColor
            activeContentColor: Config.sessionActiveContentColor
            borderRadius: Config.menuAreaButtonsBorderRadius
            borderSize: Config.sessionBorderSize
            backgroundColor: Config.sessionBackgroundColor
            backgroundOpacity: Config.sessionBackgroundOpacity
            activeBackgroundColor: Config.sessionBackgroundColor
            activeBackgroundOpacity: Config.sessionActiveBackgroundOpacity
            fontFamily: Config.menuAreaButtonsFontFamily
            activeFocusOnTab: true
            focus: false

            onClicked: {
                if (loginScreen.isSelectingUser)
                    loginScreen.isSelectingUser = false;
                else
                    popup.open();
            }

            tooltipText: "Change Session"

            Popup {
                id: popup
                parent: sessionButton
                padding: Config.menuAreaPopupsPadding
                dim: true
                onOpened: loginScreen.safeStateChange("popup")
                onClosed: loginScreen.safeStateChange("normal")
                modal: true
                popupType: Popup.Item
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                focus: visible

                Component.onCompleted: {
                    [x, y] = menuArea.calculatePopupPos(Config.sessionPopupDirection, Config.sessionPopupAlign, popup, sessionButton);
                }

                SessionSelector {
                    focus: popup.focus
                    onSessionChanged: function(newSessionIndex, sessionIcon, sessionLabel) {
                        loginScreen.sessionIndex = newSessionIndex;
                        sessionButton.icon = sessionIcon;
                        sessionButton.label = sessionButton.showLabel ? sessionLabel : "";
                    }
                    onClose: {
                        popup.close();
                    }
                }

                background: Rectangle {
                    color: Config.menuAreaPopupsBackgroundColor
                    opacity: Config.menuAreaPopupsBackgroundOpacity
                    radius: Config.menuAreaButtonsBorderRadius * Config.generalScale

                    Rectangle {
                        anchors.fill: parent
                        visible: Config.menuAreaPopupsBorderSize > 0
                        radius: parent.radius
                        color: "transparent"

                        border {
                            color: Config.menuAreaPopupsBorderColor
                            width: Config.menuAreaPopupsBorderSize * Config.generalScale
                        }
                    }
                }

                Overlay.modal: Rectangle {
                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: function(event) {
                            popup.close();
                            event.accepted = true;
                        }
                    }
                }
            }
        }
    }

    Component {
        id: layoutMenuComponent

        IconButton {
            id: layoutButton
            property bool showLabel: Config.layoutDisplayLayoutName
            height: Config.menuAreaButtonsSize * Config.generalScale
            icon: Config.getIcon(Config.layoutIcon)
            active: popup.visible
            borderRadius: Config.menuAreaButtonsBorderRadius
            borderSize: Config.layoutBorderSize
            iconSize: Config.layoutIconSize
            fontSize: Config.layoutFontSize
            backgroundColor: Config.layoutBackgroundColor
            backgroundOpacity: Config.layoutBackgroundOpacity
            activeBackgroundColor: Config.layoutBackgroundColor
            activeBackgroundOpacity: Config.layoutActiveBackgroundOpacity
            contentColor: Config.layoutContentColor
            activeContentColor: Config.layoutActiveContentColor
            fontFamily: Config.menuAreaButtonsFontFamily
            activeFocusOnTab: true
            enabled: loginScreen.state === "normal" || popup.visible
            focus: false

            onClicked: {
                if (loginScreen.isSelectingUser)
                    loginScreen.isSelectingUser = false;
                else
                    popup.open();
            }

            tooltipText: "Change Keyboard Layout"
            label: showLabel ? (keyboard && keyboard.layouts && keyboard.currentLayout >= 0 && keyboard.currentLayout < keyboard.layouts.length ? keyboard.layouts[keyboard.currentLayout].shortName.toUpperCase() : "") : ""

            Component.onDestruction: {
                if (typeof connections !== 'undefined')
                    connections.target = null;
            }

            Connections {
                function onToggleLayoutPopup() {
                    if (popup.visible)
                        popup.close();
                    else
                        popup.open();
                }

                target: loginScreen
            }

            Popup {
                id: popup
                parent: layoutButton
                padding: Config.menuAreaPopupsPadding
                focus: visible
                dim: true
                onOpened: loginScreen.safeStateChange("popup")
                onClosed: loginScreen.safeStateChange("normal")
                modal: true
                popupType: Popup.Item
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                Component.onCompleted: {
                    [x, y] = menuArea.calculatePopupPos(Config.layoutPopupDirection, Config.layoutPopupAlign, popup, layoutButton);
                }

                LayoutSelector {
                    focus: popup.focus

                    onLayoutChanged: function(index) {
                        layoutButton.label = showLabel ? (keyboard && keyboard.layouts && keyboard.currentLayout >= 0 && keyboard.currentLayout < keyboard.layouts.length ? keyboard.layouts[keyboard.currentLayout].shortName.toUpperCase() : "") : "";
                    }
                    onClose: {
                        popup.close();
                    }
                }

                background: Rectangle {
                    color: Config.menuAreaPopupsBackgroundColor
                    opacity: Config.menuAreaPopupsBackgroundOpacity
                    radius: Config.menuAreaButtonsBorderRadius * Config.generalScale

                    Rectangle {
                        anchors.fill: parent
                        visible: Config.menuAreaPopupsBorderSize > 0
                        radius: parent.radius
                        color: "transparent"

                        border {
                            color: Config.menuAreaPopupsBorderColor
                            width: Config.menuAreaPopupsBorderSize * Config.generalScale
                        }
                    }
                }

                Overlay.modal: Rectangle {
                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: function(event) {
                            popup.close();
                            event.accepted = true;
                        }
                    }
                }
            }
        }
    }

    Component {
        id: powerMenuComponent

        IconButton {
            id: powerButton
            height: Config.menuAreaButtonsSize * Config.generalScale
            width: Config.menuAreaButtonsSize * Config.generalScale
            icon: Config.getIcon(Config.powerIcon)
            iconSize: Config.powerIconSize
            contentColor: Config.powerContentColor
            activeContentColor: Config.powerActiveContentColor
            fontFamily: Config.menuAreaButtonsFontFamily
            active: popup.visible
            borderRadius: Config.menuAreaButtonsBorderRadius
            borderSize: Config.powerBorderSize
            backgroundColor: Config.powerBackgroundColor
            backgroundOpacity: Config.powerBackgroundOpacity
            activeBackgroundColor: Config.powerBackgroundColor
            activeBackgroundOpacity: Config.powerActiveBackgroundOpacity
            enabled: loginScreen.state === "normal" || popup.visible
            activeFocusOnTab: true
            focus: false

            onClicked: {
                popup.open();
            }

            tooltipText: "Power Options"

            Popup {
                id: popup

                parent: powerButton
                dim: true
                padding: Config.menuAreaPopupsPadding
                onOpened: loginScreen.safeStateChange("popup")
                onClosed: loginScreen.safeStateChange("normal")
                modal: true
                popupType: Popup.Item
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                focus: visible

                Component.onCompleted: {
                    [x, y] = menuArea.calculatePopupPos(Config.powerPopupDirection, Config.powerPopupAlign, popup, powerButton);
                }

                PowerMenu {
                    focus: popup.focus

                    onClose: {
                        popup.close();
                    }
                }

                background: Rectangle {
                    color: Config.menuAreaPopupsBackgroundColor
                    opacity: Config.menuAreaPopupsBackgroundOpacity
                    radius: Config.menuAreaButtonsBorderRadius * Config.generalScale

                    Rectangle {
                        anchors.fill: parent
                        visible: Config.menuAreaPopupsBorderSize > 0
                        radius: parent.radius
                        color: "transparent"

                        border {
                            color: Config.menuAreaPopupsBorderColor
                            width: Config.menuAreaPopupsBorderSize * Config.generalScale
                        }
                    }
                }

                Overlay.modal: Rectangle {
                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: function(event) {
                            popup.close();
                            event.accepted = true;
                        }
                    }
                }
            }
        }
    }

    Row {
        id: topLeftButtons

        height: childrenRect.height
        width: childrenRect.width
        spacing: Config.menuAreaButtonsSpacing

        anchors {
            top: parent.top
            left: parent.left
            topMargin: Config.menuAreaButtonsMarginTop
            leftMargin: Config.menuAreaButtonsMarginLeft
        }
    }

    Row {
        id: topCenterButtons
        height: childrenRect.height
        width: childrenRect.width
        spacing: Config.menuAreaButtonsSpacing

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: Config.menuAreaButtonsMarginTop
        }
    }

    Row {
        id: topRightButtons
        height: childrenRect.height
        width: childrenRect.width
        spacing: Config.menuAreaButtonsSpacing

        anchors {
            top: parent.top
            right: parent.right
            topMargin: Config.menuAreaButtonsMarginTop
            rightMargin: Config.menuAreaButtonsMarginRight
        }
    }

    Column {
        id: centerLeftButtons
        height: childrenRect.height
        width: childrenRect.width
        spacing: Config.menuAreaButtonsSpacing

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: Config.menuAreaButtonsMarginLeft
        }
    }

    Column {
        id: centerRightButtons

        height: childrenRect.height
        width: childrenRect.width
        spacing: Config.menuAreaButtonsSpacing

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: Config.menuAreaButtonsMarginRight
        }
    }

    Row {
        id: bottomLeftButtons

        height: childrenRect.height
        width: childrenRect.width
        spacing: Config.menuAreaButtonsSpacing

        anchors {
            bottom: parent.bottom
            left: parent.left
            bottomMargin: Config.menuAreaButtonsMarginBottom
            leftMargin: Config.menuAreaButtonsMarginLeft
        }
    }

    Row {
        id: bottomCenterButtons
        height: childrenRect.height
        width: childrenRect.width
        spacing: Config.menuAreaButtonsSpacing

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: Config.menuAreaButtonsMarginBottom
        }
    }

    Row {
        id: bottomRightButtons
        height: childrenRect.height
        width: childrenRect.width
        spacing: Config.menuAreaButtonsSpacing

        anchors {
            bottom: parent.bottom
            right: parent.right
            bottomMargin: Config.menuAreaButtonsMarginBottom
            rightMargin: Config.menuAreaButtonsMarginRight
        }
    }
}
