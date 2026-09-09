.pragma library

// Все раскладки декларируются здесь. Никакого хардкода в QML!
var presets = [
    {
	name: "Default Full",
	softpadHidden: false,
	dialpadHidden: false,
	keypadHidden: false,
	customKeys: []
    },
    {
	name: "Diamond Rush",
	softpadHidden: false,
	dialpadHidden: false,
	keypadHidden: true,
	customKeys: ["*", "#"]
    },
    {
	name: "Assassin's Creed",
	softpadHidden: false,
	dialpadHidden: false,
	keypadHidden: true,
	customKeys: ["3", "0", "*"]
    },
    {
	name: "Gravity Defied",
	softpadHidden: false,
	dialpadHidden: true,
	keypadHidden: true,
	customKeys: ["1", "3", "7"]
    },
    {
	name: "D-Pad Only",
	softpadHidden: true,
	dialpadHidden: false,
	keypadHidden: true,
	customKeys: []
    },
    {
	name: "NumPad Only",
	softpadHidden: true,
	dialpadHidden: true,
	keypadHidden: false,
	customKeys: []
    }
];

function getPresetNames() {
    var names = [];
    for (var i = 0; i < presets.length; i++) {
	names.push(presets[i].name);
    }
    return names;
}

function getPreset(index) {
    if (index >= 0 && index < presets.length) {
	return presets[index];
    }
    return presets[0];
}
