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
    property var foodPosition2: []
    property var foodPosition3: []
    property int direction: 0 // 0:right, 1:down, 2:left, 3:up
    property bool gameRunning: false
    property int score: 0

    property int speed: 200

    property var snakeColors: ["#00FF02", "#00DF00", "#68F200", "#ADFF00"]
    property var foodColors: ["#FF0000", "#FF5900", "#FF2A00"]
    property var food2Colors: ["#FED701", "#FDF700", "#F3F201"]
    property var food3Colors: ["#4300FE", "#0041FE", "#0AADFE"]

    function getSnakeColor() {
      return snakeColors[Math.floor(Math.random() * snakeColors.length)];
    }

    function getFoodColor() {
      return foodColors[Math.floor(Math.random() * foodColors.length)];
    }

    function getFood2Color() {
      return food2Colors[Math.floor(Math.random() * food2Colors.length)];
    }

    function getFood3Color() {
      return food3Colors[Math.floor(Math.random() * food3Colors.length)];
    }

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
                color: getColor(model.isOn, index)
            }
        }
    }

    // Control buttons
    // Row {
    //     anchors.bottom: parent.bottom
    //     anchors.bottomMargin: 50
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     spacing: 10

    //     Button {
    //         text: "←"
    //         onClicked: if (direction !== 0) direction = 2
    //     }
    //     Button {
    //         text: "↑"
    //         onClicked: if (direction !== 1) direction = 3
    //     }
    //     Button {
    //         text: "↓"
    //         onClicked: if (direction !== 3) direction = 1
    //     }
    //     Button {
    //         text: "→"
    //         onClicked: if (direction !== 2) direction = 0
    //     }
    // }

    Grid {
        rows: 3
        columns: 3

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2

        Button {
            text: ""
            opacity: 0
        }
        Button {
            text: "↑"
            onClicked: if (direction !== 1) direction = 3
        }
        Button {
            text: ""
            opacity: 0
        }
        Button {
            text: "←"
            onClicked: if (direction !== 0) direction = 2
        }
        Button {
            text: ""
            opacity: 0
        }
        Button {
            text: "→"
            onClicked: if (direction !== 2) direction = 0
        }
        Button {
            text: ""
            opacity: 0
        }
        Button {
            text: "↓"
            onClicked: if (direction !== 3) direction = 1
        }
        Button {
            text: ""
            opacity: 0
        }
    }

    // Start/Reset button
    Button {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 210
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
        generateFood2()
        generateFood3()
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

    function getColor(isOn, index) {
        if (isOn) return getSnakeColor()

        if (foodPosition[0] === Math.floor(index / gridSize) && foodPosition[1] === index % gridSize) return getFoodColor()
        if (foodPosition2[0] === Math.floor(index / gridSize) && foodPosition2[1] === index % gridSize) return getFood2Color()
        if (foodPosition3[0] === Math.floor(index / gridSize) && foodPosition3[1] === index % gridSize) return getFood3Color()

        return "black"
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

    function generateFood2() {
        const chance = Math.random()
        console.log("chance 2: ", chance)
        if (chance < 0.5) {
            foodPosition2 = [-1, -1]
            return
        }

        while (true) {
            let row = Math.floor(Math.random() * gridSize)
            let col = Math.floor(Math.random() * gridSize)
            let valid = true

            for (let pos of snakePositions) {
                if (pos[0] === row && pos[1] === col) {
                    valid = false
                    break
                }
                if (pos[0] === foodPosition[0] && pos[1] === foodPosition[1]) {
                    valid = false
                    break
                }
            }

            if (valid) {
                foodPosition2 = [row, col]
                break
            }
        }
    }

    function generateFood3() {
        const chance = Math.random()
        console.log("chance 3: ", chance)
        if (chance < 0.7) {
            foodPosition3 = [-1, -1]
            return
        }

        while (true) {
            let row = Math.floor(Math.random() * gridSize)
            let col = Math.floor(Math.random() * gridSize)
            let valid = true

            for (let pos of snakePositions) {
                if (pos[0] === row && pos[1] === col) {
                    valid = false
                    break
                }
                if (pos[0] === foodPosition[0] && pos[1] === foodPosition[1]) {
                    valid = false
                    break
                }
                if (pos[0] === foodPosition2[0] && pos[1] === foodPosition2[1]) {
                    valid = false
                    break
                }
            }

            if (valid) {
                foodPosition3 = [row, col]
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
            if (foodPosition2[0] === -1) generateFood2()
            if (foodPosition3[0] === -1) generateFood3()
        } else if (head[0] === foodPosition2[0] && head[1] === foodPosition2[1]) {
            score += 2
            speed -= 6
            generateFood2()
            if (foodPosition3[0] === -1) generateFood3()
        } else if (head[0] === foodPosition3[0] && head[1] === foodPosition3[1]) {
            score += 3
            speed -= 7
            generateFood3()
            if (foodPosition2[0] === -1) generateFood2()
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
