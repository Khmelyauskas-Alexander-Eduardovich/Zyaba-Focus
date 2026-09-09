// Убрали .pragma library, чтобы функции выполнялись в контексте вызывающего QML-объекта

function getLocalStorage() {
    return LocalStorage.openDatabaseSync("ZyabaUniversalStorage", "2.0", "Extended Storage for Future Projects", 5000000);
}

// 1. Стандартные пары ключ-значение
function saveSetting(key, value) {
    try {
	var db = getLocalStorage();
	db.transaction(function(tx) {
	    tx.executeSql('CREATE TABLE IF NOT EXISTS GlobalSettings(key TEXT UNIQUE, value TEXT)');
	    tx.executeSql('INSERT OR REPLACE INTO GlobalSettings VALUES(?, ?)', [key, value]);
	});
    } catch(err) {
	console.log("[Storage Error in saveSetting]:", err);
    }
}

function loadSetting(key, defaultValue) {
    var res = defaultValue;
    try {
	var db = getLocalStorage();
	db.transaction(function(tx) {
	    tx.executeSql('CREATE TABLE IF NOT EXISTS GlobalSettings(key TEXT UNIQUE, value TEXT)');
	    var rs = tx.executeSql('SELECT value FROM GlobalSettings WHERE key = ?;', [key]);
	    if (rs.rows.length > 0) {
		res = rs.rows.item(0).value;
	    }
	});
    } catch(err) {
	console.log("[Storage Error in loadSetting]:", err);
    }
    return res;
}

// 2. Логгер событий
function logEvent(tag, message) {
    try {
	var db = getLocalStorage();
	var timestamp = new Date().toISOString();
	db.transaction(function(tx) {
	    tx.executeSql('CREATE TABLE IF NOT EXISTS EventLogs(id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp TEXT, tag TEXT, message TEXT)');
	    tx.executeSql('INSERT INTO EventLogs(timestamp, tag, message) VALUES(?, ?, ?)', [timestamp, tag, message]);
	});
    } catch(err) {
	console.log("[Storage Error in logEvent]:", err);
    }
}

function getRecentLogs(limit) {
    var logs = [];
    try {
	var db = getLocalStorage();
	db.transaction(function(tx) {
	    tx.executeSql('CREATE TABLE IF NOT EXISTS EventLogs(id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp TEXT, tag TEXT, message TEXT)');
	    var rs = tx.executeSql('SELECT timestamp, tag, message FROM EventLogs ORDER BY id DESC LIMIT ?;', [limit || 50]);
	    for (var i = 0; i < rs.rows.length; i++) {
		logs.push(rs.rows.item(i));
	    }
	});
    } catch(err) {
	console.log("[Storage Error in getRecentLogs]:", err);
    }
    return logs;
}

// 3. Менеджер избранного / закладки
function toggleBookmark(itemId, title) {
    var exists = false;
    try {
	var db = getLocalStorage();
	db.transaction(function(tx) {
	    tx.executeSql('CREATE TABLE IF NOT EXISTS Bookmarks(itemId TEXT UNIQUE, title TEXT, addedDate TEXT)');
	    var rs = tx.executeSql('SELECT * FROM Bookmarks WHERE itemId = ?;', [itemId]);
	    if (rs.rows.length > 0) {
		tx.executeSql('DELETE FROM Bookmarks WHERE itemId = ?;', [itemId]);
		exists = false;
	    } else {
		tx.executeSql('INSERT INTO Bookmarks VALUES(?, ?, ?);', [itemId, title, new Date().toISOString()]);
		exists = true;
	    }
	});
    } catch(err) {
	console.log("[Storage Error in toggleBookmark]:", err);
    }
    return exists;
}

// 4. Генератор случайного UUID
function generateSessionId() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
	var r = Math.random() * 16 | 0, v = c === 'x' ? r : (r & 0x3 | 0x8);
	return v.toString(16);
    });
}
