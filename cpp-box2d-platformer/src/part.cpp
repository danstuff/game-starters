#include "include/part.h"

//PART TEMPLATE
PartTemplate::PartTemplate() {
    name = "";
    trigger = "";
    size = b2Vec2(0.0,0.0);
    maxChildren = 0;
}

void PartTemplate::setName(const char* cname) {
    name = cname;
}

void PartTemplate::setSize(b2Vec2 csize) {
    size = csize;
}

void PartTemplate::setTrigger(const char* ctrigger, unsigned int ctriggerLen) {
    trigger = ctrigger;
    triggerLen = ctriggerLen;
}

bool PartTemplate::addChildAnchor(b2Vec2 newChildAnchor) {
    if(maxChildren < PART_CHILD_MAX) {
        childAnchors[maxChildren] = newChildAnchor;
        maxChildren++;
        return true;
    }

    return false;
}

//PART
Part::Part() {
    //clear child arrays
    for(unsigned int i = 0; i < PART_CHILD_MAX; i++) {
        children[i] = nullptr;
    }

    parent = nullptr;

    temp = nullptr;

    world = nullptr;
    body = nullptr;
    parentJoint = nullptr;
}

void Part::setTemplate(PartTemplate* ctemp) {
    temp = ctemp;
}

void Part::create(b2World* cworld, b2Vec2 pos) {
    world = cworld;

    //set body position
    b2BodyDef bd;
    bd.position = pos;
    bd.type = b2_dynamicBody;

    //create body
    body = world->CreateBody(&bd);

    //create a collision box
    b2PolygonShape box;
    box.SetAsBox(temp->size.x, temp->size.y);

    b2FixtureDef fd;
    fd.shape = &box;
    fd.friction = 2.0;
    fd.density = 2.0;

    //assign fixture to a body
    body->CreateFixture(&fd);
}

bool Part::addChild(Part* newChild) {
    for(unsigned int i = 0; i < temp->maxChildren; i++) {
        if(children[i] == nullptr) {
            newChild->bindTo(body, temp->childAnchors[i]);
            newChild->parent = this;

            children[i] = newChild;
            return true;
        }
    }

    return false;
}

bool Part::removeChild(Part* oldChild) {
    for(unsigned int i = 0; i < temp->maxChildren; i++) {
        if(children[i] == oldChild) {
            oldChild->unbind();
            oldChild->parent = nullptr;

            children[i] = nullptr;
            return true;
        }
    }

    return false;
}

Part* Part::walk() {
    while(childIndex < temp->maxChildren) {
        childIndex++;
        if(children[childIndex-1] != nullptr) {
            return children[childIndex-1];
        }
    }

    return nullptr;
}

void Part::resetWalk() {
    childIndex = 0;
}

void Part::bindTo(b2Body* parentBody, b2Vec2 anchor) {
    b2Vec2 parentPos = parentBody->GetPosition();
    body->SetTransform(parentPos + anchor, 0);

    b2RevoluteJointDef jd;
    jd.Initialize(parentBody, body, parentPos + anchor);

    parentJoint = (b2RevoluteJoint*)world->CreateJoint(&jd);
}

void Part::unbind() {
    world->DestroyJoint(parentJoint);
}

//PART LIST
PartList::PartList() {
    clear();
}

PartTemplate* PartList::getNewTemplate() {
    if(numTemplates < PART_TEMP_MAX) {
        return &cTemplates[numTemplates++];
    }

    return nullptr;
}

Part* PartList::getNewPart() {
    if(numParts < PART_MAX) {
        return &parts[numParts++];
    }

    return nullptr;
}

Part* PartList::getNextRoot(unsigned int& i) {
    while(i < numParts) {
        i++;

        if(parts[i-1].parentJoint == nullptr) {
            return &parts[i-1];
        }
    }

    return nullptr;
}

void PartList::clear() {
    numTemplates = 0;
    numParts = 0;
}
