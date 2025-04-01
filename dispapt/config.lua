Config = {}

-- Radio frequency configurations
Config.RadioFrequencies = {
    [22] = {
        name = "SAST Stats",
        style = "default",
        color = {0, 255, 0} -- Green color for chat messages
    },
    [23] = {
        name = "SAFR Stats",
        style = "red",
        color = {255, 0, 0} -- Red color for chat messages
    },
    [55] = {
        name = "Alonzo Stats",
        style = "black",
        color = {0, 0, 0} -- Black color for chat messages
    },
    [75] = {
        name = "Vagos Stats",
        style = "yellow",
        color = {0, 0, 0} -- Black color for chat messages
    },
    [89] = {
        name = "Ballas Stats",
        style = "purple",
        color = {0, 0, 0} -- Black color for chat messages
    },
    [32] = {
        name = "Families Stats",
        style = "lime",
        color = {0, 0, 0} -- Black color for chat messages
    }
}

-- Default values for non-configured frequencies
Config.DefaultStyle = "default"
Config.DefaultColor = {0, 255, 0} -- Green color for chat messages

-- Available styles
Config.Styles = {
    default = {
        header = "rgba(30, 34, 43, 0.95)",
        text = "#4a9eff",
        border = "rgba(74, 158, 255, 0.3)",
        button = "#28a745",
        buttonHover = "#218838"
    },
    red = {
        header = "rgba(43, 30, 30, 0.95)",
        text = "#ff4a4a",
        border = "rgba(255, 74, 74, 0.3)",
        button = "#dc3545",
        buttonHover = "#c82333"
    },
    black = {
        header = "rgba(30, 30, 30, 0.95)",
        text = "#ffffff",
        border = "rgba(255, 255, 255, 0.3)",
        button = "#333333",
        buttonHover = "#444444"
    },
    purple = {
        header = "rgba(43, 30, 43, 0.95)",
        text = "#ff4aff",
        border = "rgba(255, 74, 255, 0.3)",
        button = "#9932CC",
        buttonHover = "#8A2BE2"
    },
    orange = {
        header = "rgba(43, 30, 0, 0.95)",
        text = "#ffa500",
        border = "rgba(255, 165, 0, 0.3)",
        button = "#FF8C00",
        buttonHover = "#FFA500"
    },
    yellow = {
        header = "rgba(43, 43, 0, 0.95)",
        text = "#ffff00",
        border = "rgba(255, 255, 0, 0.3)",
        button = "#FFD700",
        buttonHover = "#FFA500"
    },
    pink = {
        header = "rgba(43, 0, 43, 0.95)",
        text = "#ff69b4",
        border = "rgba(255, 105, 180, 0.3)",
        button = "#FF1493",
        buttonHover = "#FF69B4"
    },
    cyan = {
        header = "rgba(0, 43, 43, 0.95)",
        text = "#00ffff",
        border = "rgba(0, 255, 255, 0.3)",
        button = "#00CED1",
        buttonHover = "#20B2AA"
    },
    lime = {
        header = "rgba(30, 43, 0, 0.95)",
        text = "#32CD32",
        border = "rgba(50, 205, 50, 0.3)",
        button = "#32CD32",
        buttonHover = "#228B22"
    },
    gold = {
        header = "rgba(43, 30, 0, 0.95)",
        text = "#FFD700",
        border = "rgba(255, 215, 0, 0.3)",
        button = "#DAA520",
        buttonHover = "#B8860B"
    },
    silver = {
        header = "rgba(43, 43, 43, 0.95)",
        text = "#C0C0C0",
        border = "rgba(192, 192, 192, 0.3)",
        button = "#A9A9A9",
        buttonHover = "#808080"
    },
    brown = {
        header = "rgba(43, 30, 0, 0.95)",
        text = "#8B4513",
        border = "rgba(139, 69, 19, 0.3)",
        button = "#8B4513",
        buttonHover = "#654321"
    },
    maroon = {
        header = "rgba(43, 0, 0, 0.95)",
        text = "#800000",
        border = "rgba(128, 0, 0, 0.3)",
        button = "#800000",
        buttonHover = "#8B0000"
    },
    navy = {
        header = "rgba(0, 0, 43, 0.95)",
        text = "#000080",
        border = "rgba(0, 0, 128, 0.3)",
        button = "#000080",
        buttonHover = "#00008B"
    }
} 