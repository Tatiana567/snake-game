import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    id: root
    width: 600
    height: 800
    visible: true
    color: "black"
    title: "Snake Game"

    property int gridSize: 15
    property int cellSize: Math.min(width, height - 200) / gridSize
    property var snakePositions: [[7,7]]
    property var foodPosition: []
    property int direction: 0 // 0:right, 1:down, 2:left, 3:up
    property bool gameRunning: false
    property int score: 0

    property int speed: 200

    // Model for the grid cells
    ListModel {
        id: gridModel
        Component.onCompleted: {
            for(let i = 0; i < gridSize * gridSize; i++) {
                append({"isOn": false})
            }
        }
    }

    // Game grid
    GridView {
        id: gameGrid
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -100
        width: gridSize * cellSize
        height: width
        cellWidth: cellSize
        cellHeight: cellSize
        model: gridModel
        interactive: false

        delegate: Rectangle {
            width: cellSize - 1
            height: cellSize - 1
            color: "darkGray"

            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                color: model.isOn ? "green" :
                                    (foodPosition[0] === Math.floor(index / gridSize) &&
                                     foodPosition[1] === index % gridSize ? "red" : "black")
            }
        }
    }

    // Control buttons
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Button {
            text: "←"
            onClicked: if (direction !== 0) direction = 2
        }
        Button {
            text: "↑"
            onClicked: if (direction !== 1) direction = 3
        }
        Button {
            text: "↓"
            onClicked: if (direction !== 3) direction = 1
        }
        Button {
            text: "→"
            onClicked: if (direction !== 2) direction = 0
        }
    }

    // Start/Reset button
    Button {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        anchors.horizontalCenter: parent.horizontalCenter
        text: gameRunning ? "Reset" : "Start"
        onClicked: {
            if (gameRunning) {
                resetGame()
            } else {
                startGame()
            }
        }
    }

    // Score display
    Text {
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        color: "white"
        text: "Score: " + score
        font.pixelSize: 24
    }

    Timer {
        id: gameTimer
        interval: speed > 50 ? speed : 50
        repeat: true
        running: gameRunning
        onTriggered: moveSnake()
    }

    function startGame() {
        snakePositions = [[7,7]]
        direction = 0
        score = 0
        gameRunning = true
        generateFood()
        updateGrid()
    }

    function resetGame() {
        speed = 200
        gameRunning = false
        snakePositions = [[7,7]]
        direction = 0
        score = 0
        updateGrid()
    }

    function generateFood() {
        while (true) {
            let row = Math.floor(Math.random() * gridSize)
            let col = Math.floor(Math.random() * gridSize)
            let valid = true

            for (let pos of snakePositions) {
                if (pos[0] === row && pos[1] === col) {
                    valid = false
                    break
                }
            }

            if (valid) {
                foodPosition = [row, col]
                break
            }
        }
    }

    function moveSnake() {
        let head = snakePositions[0].slice()

        // Calculate new head position
        switch(direction) {
        case 0: // right
            head[1]++
            break
        case 1: // down
            head[0]++
            break
        case 2: // left
            head[1]--
            break
        case 3: // up
            head[0]--
            break
        }

        // Check for collision with walls
        if (head[0] < 0 || head[0] >= gridSize || head[1] < 0 || head[1] >= gridSize) {
            gameRunning = false
            speed = 200
            return
        }

        // Check for collision with self
        for (let pos of snakePositions) {
            if (head[0] === pos[0] && head[1] === pos[1]) {
                gameRunning = false
                speed = 200
                return
            }
        }

        // Add new head
        snakePositions.unshift(head)

        // Check if food is eaten
        if (head[0] === foodPosition[0] && head[1] === foodPosition[1]) {
            score++
            speed -= 5
            generateFood()
        } else {
            // Remove tail if no food was eaten
            snakePositions.pop()
        }

        updateGrid()
    }

    function updateGrid() {
        // Reset all cells
        for(let i = 0; i < gridSize * gridSize; i++) {
            gridModel.setProperty(i, "isOn", false)
        }

        // Set snake cells
        for (let pos of snakePositions) {
            let index = pos[0] * gridSize + pos[1]
            if (index >= 0 && index < gridSize * gridSize) {
                gridModel.setProperty(index, "isOn", true)
            }
        }
    }
}
