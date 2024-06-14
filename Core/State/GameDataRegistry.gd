extends Object
class_name GameDataRegistry

var enemies = {
    # id : [scanned,beatenNum]
}

var characters = {
    # id : [(metadata? flags?)]
}

var topics = {
    # id : [(metadata? flags?)]
}

#region Enemy operations
func registerScannedEnemy(id):
    if !enemies.has(id):
        enemies[id] = [true,0]
    else:
        enemies[id][0] = true
func registerBeatenEnemy(id):
    if !enemies.has(id):
        enemies[id] = [false,1]
    else:
        enemies[id][1] = enemies[id][1] + 1
func getEnemyList():
    return enemies.keys()
func isEnemyScanned(id):
    if enemies.has(id):
        return enemies[id][0]
    return false
func getEnemyBeaten(id):
    if enemies.has(id):
        return enemies[id][1]
    return 0
#endregion

#region Characters operations
func registerCharacter(id):
    if !characters.has(id):
        characters[id] = [0]
func getCharacterList():
    return characters.keys()
#endregion

#region Topics operations
func registerTopic(id):
    if !topics.has(id):
        topics[id] = [0]
func getTopicsList():
    return topics.keys()
#endregion

#region Serialization
func _serialize():
    var savedata = {
		"enemies" : enemies,
		"characters" : characters,
        "topics" : topics
	}
    return savedata
func _deserialize(savedata : Dictionary):
    for key in savedata:
        set(key, savedata[key])
#endregion