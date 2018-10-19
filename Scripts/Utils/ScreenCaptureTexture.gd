extends Sprite

export(int) var slot

var tex

func _ready():
    var path = "user://screenshot" + str(slot) + ".png"
    var dir = Directory.new()
    
    if dir.file_exists(path):
        var img = Image.new()
        img.load(path)
        
        var sizing = 1024.0 / img.get_width()

        self.scale = Vector2(sizing, sizing)

        tex = ImageTexture.new()
        tex.create_from_image(img)
        self.texture = tex