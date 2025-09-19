/**
 * @File Name          : JSONTree.cls
 * @Description        : Lets you build a json with simple dot notation
 * @Author             : Clifford Beul
 * @Last Modified By   : c.beul
 * @Last Modified On   : 15.4.2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0       15.4.2021       c.beul                 Initial Version
**/
public with sharing class JsonTree {
    public Node root;

    public JsonTree () {
        reset();
    }

    /**
     * @description Resets the JSONTree and all key-values will be deleted
     */
    public void reset() {
        this.root = new Node('root');
        this.root.setRoot(true);
    }

    /**
     * @description Create a JSON out of the existing JSONTree
     * @return   returns a JSON As String
     */
    public String build() {
        JSONGenerator gen = JSON.createGenerator(false);
        this.root.traverse(gen);

        return gen.getAsString();
    }

    /**
     * @description Sinks a new JSON Key Value Pair into the JSONTree
     * @param  path  The path formatted as dot notation. The String after the last dot will be used as key
     * @param  value The value you want to insert
     */
    public void sink(String path, Object value) {
        List<String> parts = path.split('\\.');
        String key = parts.remove(parts.size() - 1);
        sink(parts, key, value);
    }

    /**
     * @description Sinks a new JSON Key Value Pair into the JSONTree
     * @param  path  The path formatted as dot notation.
     * @param  key   The name of the key
     * @param  value The value you want to insert
     */
    public void sink(String path, String key, Object value) {
        if (String.isNotBlank(path)) {
            sink(path.split('\\.'), key, value);
        } else {
            sink(new List<String>(), key, value);
        }
    }

    /**
     * @description Sinks a new JSON Key Value Pair into the JSONTree
     * @param  path  The path represented as a List. The Key-Value Pair will be added to the last List Element
     * @param  key   The name of the key
     * @param  value The value you want to insert
     */
    private void sink(List<String> path, String key, Object value) {
        this.root.sink(path, key, value);
    }

    /**
     * Represents a Tree Node
     */
    public class Node {
        private String name;
        private Boolean isRoot = false;
        private Map<String, Node> children = new Map<String, Node>();
        private Map<String, Object> items = new Map<String, Object>();

        public Node(String name) {
            this.name = name;
        }

        /**
         * @description Set a tree node as root or not
         * @param  isRoot Boolean isRoot
         */
        public void setRoot(Boolean isRoot) {
            this.isRoot = isRoot;
        }

        /**
         * @description Adds a child to this tree node
         * @param  name the name of the child node
         * @return      the new child node or if one with the same name exists, the existing one
         */
        public Node addChild(String name) {
            if (!this.children.containsKey(name)) {
                Node child = new Node(name);

                this.children.put(name, child);
                return child;
            } else {
                return this.children.get(name);
            }
        }

        /**
         * @description Traverses through Child nodes and builds a json
         * @param  gen A JSONGenerator
         */
        public void traverse(JSONGenerator gen) {
            if (this.isRoot == false) {
                gen.writeFieldName(this.name);
            }

            gen.writeStartObject();

            for (String key : items.keySet()) {
                Object value = items.get(key);
                if (value instanceof List<JsonTree>) {
                    List<Map<String, Object>> buildedJsonTrees = new List<Map<String, Object>>();
                    List<JsonTree> jsonTrees = (List<JsonTree>) value;
                    for (JsonTree jsTree : jsonTrees) {
                        buildedJsonTrees.add((Map<String,Object>)JSON.deserializeUntyped(jsTree.build()));
                    }
                    value = buildedJsonTrees;
                }
                if(value == null) {
                    gen.writeNullField(key);
                }
                else {
                    gen.writeObjectField(key, value);
                }
            }

            for (Node child : this.children.values()) {
                child.traverse(gen);
            }

            gen.writeEndObject();
        }

        /**
         * @description Sinks a new key value pair into the JSONTree
         * @param  path  the path of where the key-value pair should be located as String List: 'Student', 'Details'
         * @param  key   The name of the JSON Key
         * @param  value The JSON Value
         */
        public void sink(List<String> path, String key, Object value) {
            if (path.isEmpty()) {
                this.items.put(key, value);
            } else {
                String name = path.remove(0);
                Node child = addChild(name);
                child.sink(path, key, value);
            }
        }

    }

}