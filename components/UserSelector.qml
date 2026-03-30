import QtQuick
import QtQuick.Controls
import SddmComponents

Item {
    id: selector

    property bool listUsers: false
    property string orientation: ""
    property bool isDragging: false

    signal openUserList()
    signal closeUserList()
    signal userChanged(int userIndex, string username, string userRealName, string userIcon, bool needsPassword)

    function prevUser() {
        userList.decrementCurrentIndex();
    }

    function nextUser() {
        userList.incrementCurrentIndex();
    }

    Keys.onPressed: function(event) {
        if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter || event.key === Qt.Key_Space) {
            if (selector.listUsers) {
                selector.closeUserList();
                selector.focus = false;
            } else {
                selector.openUserList();
                selector.focus = true;
            }
            event.accepted = true;
        } else if (event.key == Qt.Key_Escape) {
            selector.closeUserList();
            selector.focus = false;
            event.accepted = true;
        } else if ((selector.orientation === "horizontal" && event.key == Qt.Key_Left) || (selector.orientation === "vertical" && event.key == Qt.Key_Up)) {
            if (userModel.rowCount() > 0)
                userList.currentIndex = (userList.currentIndex + userModel.rowCount() - 1) % userModel.rowCount();

            selector.focus = true;
            event.accepted = true;
        } else if ((selector.orientation === "horizontal" && event.key == Qt.Key_Right) || (selector.orientation === "vertical" && event.key == Qt.Key_Down)) {
            if (userModel.rowCount() > 0)
                userList.currentIndex = (userList.currentIndex + userModel.rowCount() + 1) % userModel.rowCount();

            selector.focus = true;
            event.accepted = true;
        } else if (event.key === Qt.Key_CapsLock) {
            root.capsLockOn = !root.capsLockOn;
            event.accepted = true;
        } else {
            event.accepted = false;
        }
    }

    ListView {
        id: userList

        anchors.fill: parent
        orientation: selector.orientation === "horizontal" ? ListView.Horizontal : ListView.Vertical
        spacing: 10
        interactive: false
        boundsBehavior: Flickable.StopAtBounds
        preferredHighlightBegin: selector.orientation === "horizontal" ? (width - Config.avatarActiveSize * Config.generalScale) / 2 : (height - Config.avatarActiveSize * Config.generalScale) / 2
        preferredHighlightEnd: preferredHighlightBegin
        highlightRangeMode: ListView.StrictlyEnforceRange
        leftMargin: selector.orientation === "horizontal" ? preferredHighlightBegin : 0
        rightMargin: leftMargin
        topMargin: selector.orientation === "horizontal" ? 0 : preferredHighlightBegin
        bottomMargin: topMargin
        highlightMoveDuration: 200
        highlightResizeDuration: 200
        highlightMoveVelocity: -1
        highlightFollowsCurrentItem: true
        model: userModel
        currentIndex: userModel.lastIndex
        onCurrentIndexChanged: {
            var username = userModel.data(userModel.index(currentIndex, 0), 257);
            var userRealName = userModel.data(userModel.index(currentIndex, 0), 258);
            var userIcon = userModel.data(userModel.index(currentIndex, 0), 260);
            var needsPasswd = userModel.data(userModel.index(currentIndex, 0), 261);
            sddm.currentUser = username;
            selector.userChanged(currentIndex, username, userRealName, userIcon, needsPasswd);
        }

        delegate: Rectangle {
            width: index === userList.currentIndex ? (Config.avatarActiveSize * Config.generalScale) : (Config.avatarInactiveSize * Config.generalScale)
            height: index === userList.currentIndex ? (Config.avatarActiveSize * Config.generalScale) : (Config.avatarInactiveSize * Config.generalScale)
            color: "transparent"
            visible: selector.listUsers || index === userList.currentIndex
            opacity: selector.listUsers || index === userList.currentIndex ? 1 : 0

            anchors {
                verticalCenter: selector.orientation === "horizontal" ? parent.verticalCenter : undefined
                horizontalCenter: selector.orientation === "horizontal" ? undefined : parent.horizontalCenter
            }

            Avatar {
                width: parent.width
                height: parent.height
                source: model.icon
                active: index === userList.currentIndex
                opacity: active ? 1 : Config.avatarInactiveOpacity
                enabled: userModel.rowCount() > 1
                tooltipText: active && selector.listUsers ? "Close user selection" : (active && !listUsers ? "Select user" : `Select user ${model.name}`)
                showTooltip: selector.focus && !listUsers && active
                onClicked: {
                    if (!selector.listUsers) {
                        selector.openUserList();
                        selector.focus = true;
                        userList.model.reset();
                    } else {
                        if (index === userList.currentIndex) {
                            selector.closeUserList();
                            selector.focus = false;
                        }
                        userList.currentIndex = index;
                    }
                }
                onClickedOutside: {
                    selector.closeUserList();
                    selector.focus = false;
                }

                Behavior on opacity {
                    enabled: Config.enableAnimations

                    NumberAnimation {
                        duration: 200
                    }

                }

            }

            Behavior on width {
                enabled: Config.enableAnimations

                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }

            }

            Behavior on height {
                enabled: Config.enableAnimations

                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }

            }

            Behavior on opacity {
                enabled: Config.enableAnimations

                NumberAnimation {
                    duration: 200
                }

            }

        }

    }

}
