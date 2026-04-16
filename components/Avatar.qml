import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
    id: avatar

    property string shape: Config.avatarShape
    property string source: ""
    property bool active: false
    property bool hasValidSource: source !== "" && faceImage.status === Image.Ready
    property int squareRadius: (shape == "circle") ? this.width : (Config.avatarBorderRadius === 0 ? 1 : Config.avatarBorderRadius * Config.generalScale)
    property bool drawStroke: (active && Config.avatarActiveBorderSize > 0) || (!active && Config.avatarInactiveBorderSize > 0)
    property color strokeColor: active ? Config.avatarActiveBorderColor : Config.avatarInactiveBorderColor
    property int strokeSize: active ? (Config.avatarActiveBorderSize * Config.generalScale) : (Config.avatarInactiveBorderSize * Config.generalScale)
    property string tooltipText: ""
    property bool showTooltip: false

    signal clicked()
    signal clickedOutside()

    radius: squareRadius
    color: "transparent"
    antialiasing: true

    Image {
        id: faceImage

        source: parent.source
        anchors.fill: parent
        mipmap: true
        antialiasing: true
        visible: false
        smooth: true
        fillMode: Image.PreserveAspectCrop
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter

        Rectangle {
            anchors.fill: parent
            radius: avatar.squareRadius
            color: "transparent"
            border.width: avatar.strokeSize
            border.color: avatar.strokeColor
            antialiasing: true
        }

    }

    MultiEffect {
        anchors.fill: faceImage
        antialiasing: true
        maskEnabled: true
        maskSource: faceImageMask
        maskSpreadAtMin: 1
        maskThresholdMax: 1
        maskThresholdMin: 0.5
        source: faceImage
    }

    Item {
        id: faceImageMask

        height: this.width
        layer.enabled: true
        layer.smooth: true
        visible: false
        width: faceImage.width

        Rectangle {
            height: this.width
            radius: avatar.squareRadius
            width: faceImage.width
        }

    }

    Rectangle {
        id: placeholderBackground

        anchors.fill: parent
        radius: avatar.squareRadius
        color: "#26FFFFFF"
        visible: !avatar.hasValidSource
        antialiasing: true

        Image {
            id: placeholderIcon

            source: Config.getIcon("user-default")
            anchors.centerIn: parent
            width: parent.width * 0.6
            height: width
            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectFit
            mipmap: true
            antialiasing: true
            smooth: true
        }

    }

    MouseArea {
        id: mouseArea

        function isCursorInsideAvatar() {
            if (!mouseArea.containsMouse)
                return false;

            if (avatar.shape === "square")
                return true;

            var centerX = width / 2;
            var centerY = height / 2;
            var radiusX = centerX;
            var radiusY = centerY;
            var dx = (mouseArea.mouseX - centerX) / radiusX;
            var dy = (mouseArea.mouseY - centerY) / radiusY;
            return (dx * dx + dy * dy) <= 1;
        }

        function updateHover() {
            if (isCursorInsideAvatar())
                cursorShape = Qt.PointingHandCursor;
            else
                cursorShape = Qt.ArrowCursor;
        }

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.ArrowCursor
        onReleased: function(mouse) {
            var isInside = isCursorInsideAvatar();
            if (isInside)
                avatar.clicked();
            else
                avatar.clickedOutside();
            mouse.accepted = isInside;
        }

        onMouseXChanged: updateHover()
        onMouseYChanged: updateHover()

        ToolTip {
            property bool shouldShow: enabled && avatar.showTooltip || (enabled && mouseArea.isCursorInsideAvatar() && avatar.tooltipText !== "")

            parent: mouseArea
            enabled: Config.tooltipsEnable && !Config.tooltipsDisableUser
            visible: shouldShow
            delay: 300

            contentItem: Text {
                font.family: Config.tooltipsFontFamily
                font.pixelSize: Config.tooltipsFontSize * Config.generalScale
                text: avatar.tooltipText
                color: Config.tooltipsContentColor
            }

            background: Rectangle {
                color: Config.tooltipsBackgroundColor
                opacity: Config.tooltipsBackgroundOpacity
                border.width: 0
                radius: Config.tooltipsBorderRadius * Config.generalScale
            }
        }
    }
}
