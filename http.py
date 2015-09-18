import MyGame.Sample.Monster as monster
import MyGame.Sample.Vec3 as vec3
import flatbuffers

import webapp2

class MainPage(webapp2.RequestHandler):
    def get(self):
        # i'm not sure when the initial size would ever be non-zero
        builder = flatbuffers.Builder(0)

        name = builder.CreateString("sean")

        # vectors are constructed in reverse order
        inv = monster.MonsterStartInventoryVector(builder, 5)
        for i in range(0, 5):
            builder.PrependByte(i)
        inv = builder.EndVector(5)

        monster.MonsterStart(builder)
        monster.MonsterAddPos(builder, vec3.CreateVec3(builder, 1.0, 2.0, 3.0))
        monster.MonsterAddHp(builder, 80)
        monster.MonsterAddName(builder, name)
        monster.MonsterAddInventory(builder, inv)
        mon = monster.MonsterEnd(builder)

        # call this after finishing your root object
        builder.Finish(mon)

        # get the bytearray
        flatbuffer = builder.Output()

        self.response.headers['Content-Type'] = 'application/octet-stream'
        #self.response.app_iter = iter(flatbuffer)
        print len(flatbuffer)
        self.response.body = bytes(flatbuffer)

    def post(self):
        print len(self.request.body)
        m = monster.Monster.GetRootAsMonster(self.request.body, 0)
        print m.Pos().X()
        print m.Pos().Y()
        print m.Pos().Z()
        print m.Hp()
        print m.Name()
        print m.InventoryLength()
        print m.Inventory(0)
        print m.Inventory(4)

        self.response.body = "sup"

app = webapp2.WSGIApplication([
    ('/', MainPage),
], debug=True)
