/**
 * @File Name          : JsonUntypedParser.cls
 * @Description        : The JsonUntypedParser allows you to access a json dynamically,
 *                       if you provide a path to the correct method. Some example paths:
 *                          1. [4].myObject
 *                          2. myobject.another.myarray[8].name
 *                          3. myarray[5]
 *                          4. [2]
 * @Author             : Clifford Beul
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0       2022-05-08      Clifford Beul          Initial Version
**/
public with sharing class JsonUntypedParser {
    private Object jsonObject;
    private Object pointer;
    private Boolean throwUndefined = false;

    @TestVisible
    private static Map<String, Object> json2deserializedObject = new Map<String, Object>();

    public enum TokenType {ARRAY_ELEMENT, JSON_ARRAY, VALUE}

    /**
     * @description Creates a new JsonUntypedParser with a json as a String
     * @param  jsonString the json you want to parse as a String.
     */
    public JsonUntypedParser(String jsonString) {
        this(jsonString, false);
    }

    /**
     * @description Creates a new JsonUntypedParser with a json as a String
     * @param  jsonString the json you want to parse as a String.
     * @param enableCache if true, the Parser will cache the deserialized json
     *                    for the transaction or use an already cached deserialzed json.
     */
    public JsonUntypedParser(String jsonString, Boolean enableCache) {
        if (!enableCache) {
            this.jsonObject = JSON.deserializeUntyped(jsonString);
            return;
        }

        Blob targetBlob = Blob.valueOf(jsonString);
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        String hashString = EncodingUtil.base64Encode(hash);

        if (json2deserializedObject.containsKey(hashString)) {
            this.jsonObject = json2deserializedObject.get(hashString);
        } else {
            this.jsonObject = JSON.deserializeUntyped(jsonString);
            json2deserializedObject.put(hashString, this.jsonObject);
        }
    }

    /**
     * @description Creates a new JsonUntypedParser with an already untyped
     *              deserialized json
     * @param  deserializedJson an untyped deserialized json
     */
    public JsonUntypedParser(Object deserializedJson) {
        this.jsonObject = deserializedJson;
    }

    /**
     * @description If set, the Parser will throw an UndefinedException
     *              in case a value does not exist. Otherwise null is returned.
     * @return   current JsonUntypedParser
     */
    public JsonUntypedParser throwUndefined() {
        this.throwUndefined = true;
        return this;
    }

    /**
     * @description Retrieves the complete deserialized Json
     * @return      an Object that holds the deserialized json
     */
    public Object getDeserializedJson() {
        return this.jsonObject;
    }

    /**
     * @description Retrieves a Boolean of the deserialized json by recursively
     *              going through a token stream. In case null or an empty String
     *              is provided as a path, the method tries to return the whole json
     *              as a Boolean.
     * @param  path a path as String e.g. myobject.myarray[3].myvalue
     * @return      the Boolean where the token stream leads to.
     *              if something is accessed, that does not exist, null is returned.
     */
    public Boolean getBoolean(String path) {
        return (Boolean) get(path);
    }

    /**
     * @description Retrieves a Blob of the deserialized json by recursively
     *              going through a token stream. In case null or an empty String
     *              is provided as a path, the method tries to return the whole json
     *              as a Blob.
     * @param  path a path as String e.g. myobject.myarray[3].myvalue
     * @return      the Blob where the token stream leads to.
     *              if something is accessed, that does not exist, null is returned.
     */
    public Blob getBlob(String path) {
        String s = getString(path);
        return s == null ? null : Blob.valueOf(s);
    }

    /**
     * @description Retrieves a Date of the deserialized json by recursively
     *              going through a token stream. In case null or an empty String
     *              is provided as a path, the method tries to return the whole json
     *              as a Date.
     * @param  path a path as String e.g. myobject.myarray[3].myvalue
     * @return      the Date where the token stream leads to.
     *              if something is accessed, that does not exist, null is returned.
     */
    public Date getDate(String path) {
        return Date.valueOf(getString(path));
    }

    /**
     * @description Retrieves a Datetime of the deserialized json by recursively
     *              going through a token stream. In case null or an empty String
     *              is provided as a path, the method tries to return the whole json
     *              as a Datetime.
     * @param  path a path as String e.g. myobject.myarray[3].myvalue
     * @return      the Datetime where the token stream leads to.
     *              if something is accessed, that does not exist, null is returned.
     */
    public Datetime getDatetime(String path) {
        String s = getString(path);

        if (s == null) {
            return null;
        }

        JSONParser parser = JSON.createParser('["' + s + '"]');
        parser.nextToken();
        parser.nextValue();
        return parser.getDatetimeValue();
    }

    /**
     * @description Retrieves a Decimal of the deserialized json by recursively
     *              going through a token stream. In case null or an empty String
     *              is provided as a path, the method tries to return the whole json
     *              as a Decimal.
     * @param  path a path as String e.g. myobject.myarray[3].myvalue
     * @return      the Decimal where the token stream leads to.
     *              if something is accessed, that does not exist, null is returned.
     */
    public Decimal getDecimal(String path) {
        return (Decimal)get(path);
    }

    /**
     * @description Retrieves a Double of the deserialized json by recursively
     *              going through a token stream. In case null or an empty String
     *              is provided as a path, the method tries to return the whole json
     *              as a Double.
     * @param  path a path as String e.g. myobject.myarray[3].myvalue
     * @return      the Double where the token stream leads to.
     *              if something is accessed, that does not exist, null is returned.
     */
    public Double getDouble(String path) {
        return (Double)get(path);
    }

    /**
     * @description Retrieves an Id of the deserialized json by recursively
     *              going through a token stream. In case null or an empty String
     *              is provided as a path, the method tries to return the whole json
     *              as an Id.
     * @param  path a path as String e.g. myobject.myarray[3].myvalue
     * @return      the Id where the token stream leads to.
     *              if something is accessed, that does not exist, null is returned.
     */
    public Id getId(String path) {
        return (Id)get(path);
    }

    /**
     * @description Retrieves an Integer of the deserialized json by recursively
     *              going through a token stream. In case null or an empty String
     *              is provided as a path, the method tries to return the whole json
     *              as an Integer.
     * @param  path a path as String e.g. myobject.myarray[3].myvalue
     * @return      the Integer where the token stream leads to.
     *              if something is accessed, that does not exist, null is returned.
     */
    public Integer getInteger(String path) {
        return (Integer)get(path);
    }

    /**
     * @description Retrieves a part of the deserialized json by recursively
     *              going through a token stream. The retrieved part is returned
     *              as a valid json. In case null or an empty String
     *              is provided as a path, the method returns the whole json back
     *              serialized again.
     * @param  path a path as String e.g. myobject.myarray
     * @return      a String with the serialized json where the token stream leads to.
     *              if something is accessed, that does not exist, null is returned.
     */
    public String getJson(String path) {
        JSONGenerator gen = JSON.createGenerator(true);

        Object currentValue = get(path);
        if (currentValue == null) {
            gen.writeNull();
        } else {
            gen.writeObject(currentValue);
        }

        return gen.getAsString();
    }

    /**
     * @description Retrieves a Long  of the deserialized json by recursively
     *              going through a token stream. In case null or an empty String
     *              is provided as a path, the method tries to return the whole json
     *              as a Long.
     * @param  path a path as String e.g. myobject.myarray[3].myvalue
     * @return      the Long where the token stream leads to.
     *              if something is accessed, that does not exist, null is returned.
     */
    public Long getLong(String path) {
        return (Long)get(path);
    }

    /**
     * @description Retrieves a String  of the deserialized json by recursively
     *              going through a token stream. In case null or an empty String
     *              is provided as a path, the method tries to return the whole json
     *              as a String.
     * @param  path a path as String e.g. myobject.myarray[3].myvalue
     * @return      the String where the token stream leads to.
     *              if something is accessed, that does not exist, null is returned.
     */
    public String getString(String path) {
        Object s = get(path);
        return s == null ? null : String.valueOf(s);
    }

    /**
     * @description Retrieves a Time of the deserialized json by recursively
     *              going through a token stream. In case null or an empty String
     *              is provided as a path, the method tries to return the whole json
     *              as a Time.
     * @param  path a path as String e.g. myobject.myarray[3].myvalue
     * @return      the Time where the token stream leads to.
     *              if something is accessed, that does not exist, null is returned.
     */
    public Time getTime(String path) {
        String s = getString(path);

        if (s == null) {
            return null;
        }

        JSONParser parser = JSON.createParser('["' + s + '"]');
        parser.nextToken();
        parser.nextValue();
        return parser.getTimeValue();
    }
    
    /**
     * @description Retrieves something of the deserialized json by recursively
     *              going through a token stream. This method can also retrieve
     *              whole subparts of a json like a List. Some example paths:
     *              1. [4].myObject
     *              2. myobject.another.myarray[8].name
     *              3. myarray[5]
     *              4. [2]
     *              In case null or an empty String is provided as a path, the method
     *              will return the whole json as an Object. This is true for all the
     *              other getters in the class, except that they are trying to return
     *              the correct type.
     * @param  path a path as String e.g. myobject.myarray[3].myvalue
     * @return      the Object where the token stream leads to.
     *              if something is accessed, that does not exist, null is returned.
     */
    public Object get(String path) {
        pointer = jsonObject;
        return getRecursive(String.isBlank(path) ? new List<String>() : path.split('\\.'));
    }

    /**
     * @description Retrieves something of the deserialized json by recursively
     *              going through a token stream
     * @param  tokenStream a List<String> with the token stream
     * @return             the Object where the token stream leads to.
     *                     if something is accessed, that does not exist, null is returned.
     */
    private Object getRecursive(List<String> tokenStream) {
        if (tokenStream.isEmpty()) {
            return this.pointer;
        }

        String currentToken = tokenStream.remove(0);

        switch on getTokenType(currentToken) {

            // e.g. [42]
            when ARRAY_ELEMENT {     
                Integer index = extractArrayIndex(currentToken);

                // Checks if the value is an array and has the index
                if( !isArray(pointer) || !hasIndex(pointer, index)) {
                    return handleUndefined();
                }

                pointer = ((List<Object>)pointer).get(index);
            }

            // e.g. clifford[42]
            when JSON_ARRAY {
                String arrayName = extractArrayName(currentToken);
                Integer index = extractArrayIndex(currentToken);

                // Checks if the key exists
                if (!isKeyValuePairs(pointer) || !containsKey(pointer, arrayname)) {
                    return handleUndefined();
                }
                pointer = ((Map<String,Object>)pointer).get(arrayName);

                // Checks if the value is an array and has the index
                if(!isArray(pointer) || !hasIndex(pointer, index)) {
                    return handleUndefined();
                }
                pointer = ((List<Object>)pointer).get(index);    
            }

            // e.g. clifford
            when VALUE {
                // Checks if the key value pair exists
                if (!isKeyValuePairs(pointer) || !containsKey(pointer, currentToken)) {
                    return handleUndefined();
                }
                pointer = ((Map<String,Object>)pointer).get(currentToken);
            }
        }

        return getRecursive(tokenStream);
    }

    /**
     * @description Gets the Type of a token.
     *              Examples:
     *              1. [0] results in ARRAY_ELEMENT
     *              2. myArray[5] results in JSON_ARRAY
     *              3. myValue results in VALUE
     * @param  token a token as a String
     * @return       Tokentype
     */
    private TokenType getTokenType(String token) {
        if (token.startsWith('[')) {
            return TokenType.ARRAY_ELEMENT;
        }

        if (token.endsWith(']')) {
            return TokenType.JSON_ARRAY;
        }

        return TokenType.VALUE;
    }

    /**
     * @description Extracts the index of an array access token
     * @param  token a String e.g. myArray[2]
     * @return       an Integer e.g. 2
     */
    private Integer extractArrayIndex(String token) {
        Integer lastIndex = token.lastIndexOf('[');
        return Integer.valueOf(token.substring(lastIndex+1, token.length()-1));
    }

    /**
     * @description Extracts the name of an array access token
     * 
     * @param  token a String e.g. myArray[2]
     * @return       a String with the arrayname e.g. myArray
     */
    private String extractArrayName(String token) {
        return token.substringBeforeLast('[');
    }
    
    /**
     * @description Checks if an Object is an array
     * @param  obj the Object to check
     * @return     true if it is, else false
     */
    private Boolean isArray(Object obj) {
        return obj instanceof List<Object>;
    }

    /**
     * @description Checks if an index is not out of bounds
     * @param  myArray Object that points to an array
     * @param  index   index as Integer to check
     * @return         true if the index is not out of bounds, else false
     */
    private Boolean hasIndex(Object myArray, Integer index) {
        return index < ((List<Object>)myArray).size();
    }

    /**
     * @description Checks if an Object is of type Map<String, Object>
     * @param  obj Object to check
     * @return     true if it is, else false
     */
    private Boolean isKeyValuePairs(Object obj) {
        return obj instanceof Map<String,Object>;
    }

    /**
     * @description Checks if an Object contains a specific key value pair
     * @param  obj the Object to check
     * @param  key the "key" of the key value pair
     * @return     true if contains the key, else false
     */
    private Boolean containsKey(Object obj, String key) {
        return ((Map<String,Object>)obj).containsKey(key);
    }

    /**
     * @description Decides what happens if a non existing value is encountered
     * @return   returns null or throws an UndefinedException,
     *           if throwUndefined() has been called before.
     */
    private Object handleUndefined() {
        if (this.throwUndefined) {
            throw new UndefinedException();
        }

        return null;
    }

    public class UndefinedException extends Exception {}
 }