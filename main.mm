#include <iostream>
#include <string>

#import <Foundation/Foundation.h>

#include "monster_generated.h"

#define PORT "11080"

enum class Verb {
    kGet,
    kPost
};

static std::string request(const std::string &url, const Verb verb = Verb::kGet, const std::string *body = nullptr);

int main() {
    // let's read a buffer!!!
    auto response = request("http://localhost:" PORT);
    auto monster = MyGame::Sample::GetMonster(response.c_str());
    std::cout << "pos = (" << monster->pos()->x() << ", " << monster->pos()->y() << ", " << monster->pos()->z() << ")\n";
    std::cout << "hp = " << monster->hp() << std::endl;
    std::cout << "name = " << monster->name()->c_str() << std::endl;
    std::cout << "inventory(" << monster->inventory()->size() << ") = {";
    for (auto i : *monster->inventory()) {
        // cout thinks i is a char if you dont cast
        std::cout << static_cast<unsigned>(i) << ", ";
    }
    std::cout << "}\n";

    // let's write a buffer!!!
    flatbuffers::FlatBufferBuilder fbb;
    auto name = fbb.CreateString("mike");
    unsigned char inv[] = { 5, 3, 4, 7 };
    auto inventory = fbb.CreateVector(inv, 4); // second arg is the length of the vector
    MyGame::Sample::Vec3 vec(1, 2, 3); // structs are created normally
    auto mloc = MyGame::Sample::CreateMonster(fbb, &vec, 150, 80, name, inventory, MyGame::Sample::Color_Red);
    MyGame::Sample::FinishMonsterBuffer(fbb, mloc);
    std::string buffer(reinterpret_cast<char *>(fbb.GetBufferPointer()), fbb.GetSize());
    response = request("http://localhost:" PORT, Verb::kPost, &buffer);
    std::cout << buffer.length();
    std::cout << response;

    // see https://google.github.io/flatbuffers/md__cpp_usage.html for more ways to create a monster
    return 0;
}

// nothing interesting to see here...
static std::string request(const std::string &url, const Verb verb, const std::string *body) {
    NSString *nsUri = [NSString stringWithUTF8String: url.c_str()];
    NSURL *nsUrl = [NSURL URLWithString: nsUri];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: nsUrl];

    request.HTTPMethod = (verb == Verb::kGet ? @"GET" : @"POST");

    if (body) {
        request.HTTPBody = [NSData dataWithBytes: body->c_str() length: body->length()];
    }

    NSData* data = [NSURLConnection sendSynchronousRequest: request returningResponse: nullptr error: nullptr];
    return std::string{(char *)data.bytes, data.length};
}
