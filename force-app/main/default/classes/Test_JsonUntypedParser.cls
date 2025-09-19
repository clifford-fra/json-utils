/**
 * @File Name          : Test_JsonUntypedParser.cls
 * @Description        : Tests the JsonUntypedParser
 * @Author             : Clifford Beul
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0       2022-05-08      Clifford Beul          Initial Version
**/
@IsTest
private with sharing class Test_JsonUntypedParser {
    
    static String getMockJson() {
        return '{\n' +
                    ' "description" :"An appliance",\n' +
                    ' "accessories" : [ "powerCord", ' + 
                                        '{ "right":"door handle1", ' + 
                                            '"left":"door handle2" } ],\n' +
                    ' "dimensions" : ' + 
                            '{ "height" : 5.5 , ' + 
                                '"width" : 3.0 , ' + 
                                '"depth" : 2.2 },\n' +
                    ' "type" : null,\n' +
                    ' "inventory" : 2000,\n' +
                    ' "price" : 1023.45,\n' +
                    ' "isShipped" : true,\n' +
                    ' "modelNumber" : "123",\n' +
                    ' "dateOfBirth" : "1988-05-13",\n' +
                    ' "sid" : "0061q00000ERagyAAD",\n' +
                    ' "now" : "2013-10-21T13:28:06.419Z",\n' +
                    ' "arrivalTime" : "18:05" \n' +
                '}';
    }

    @IsTest
    static void testGetDeserializedJson() {
        JsonUntypedParser parser = new JsonUntypedParser(getMockJson());

        Test.startTest();
        JsonUntypedParser secondParser = new JsonUntypedParser(parser.getDeserializedJson());
        Test.stopTest();

        System.assertEquals(
                parser.get('description'),
                secondParser.get('description'),
                'different jsons');
    }

    @IsTest
    static void testGet() {
        JsonUntypedParser parser = new JsonUntypedParser(getMockJson());
        JSONUntypedParser parserArray = new JsonUntypedParser('["hallo","Welt"]');

        Test.startTest();
        //Parsing Key-Value Pairs
        Object accessory = parser.get('accessories[1].right');

        // Parsing Missing Values
        Object noValue = parser.get('something.went[42].wrong');
        Object noArrayElement = parser.get('[42]');
        Object noJsonArray = parser.get('something[42]');
        Object noArrayButValue = parser.get('description[0]');
        Object noIndex = parser.get('accessories[100]');
        Object noValueButArray = parser.get('accessories.something');

        // Parsing Array
        Object hallo = parserArray.get('[0]');
        Test.stopTest();

        System.assertEquals('door handle1', accessory, 'Wrong object retrieved');
        System.assertEquals(null, noValue, 'Something was retrieved');
        System.assertEquals(null, noArrayElement, 'Something was retrieved');
        System.assertEquals(null, noJsonArray, 'Something was retrieved');
        System.assertEquals(null, noArrayButValue, 'Something was retrieved');
        System.assertEquals(null, noIndex, 'Something was retrieved');
        System.assertEquals(null, noValueButArray, 'Something was retrieved');

        System.assertEquals('hallo', hallo, 'Wrong Object retrieved');
    }

    @IsTest
    static void testGetUndefined() {
        JsonUntypedParser parser = new JsonUntypedParser(getMockJson())
                                            .throwUndefined();

        Boolean exceptionAppeared = false;

        Test.startTest();
        try {
            parser.get('something.else');
        } catch (JsonUntypedParser.UndefinedException e) {
            exceptionAppeared = true;
        }
        Test.stopTest();

        System.assert(exceptionAppeared, 'An UndefinedException was not thrown');
    } 

    @IsTest
    static void testGetJson() {
        JsonUntypedParser parser = new JsonUntypedParser(getMockJson());

        Test.startTest();
        String jsonString = parser.getJson('accessories');
        String nullString = parser.getJson('type');
        Test.stopTest();

        System.assert(jsonString.contains('powerCord'), 'Did not convert correct');
        System.assertEquals('null', nullString, 'json was not null');
    }

    @IsTest
    static void testGetDate() {
        JsonUntypedParser parser = new JsonUntypedParser(getMockJson());

        Test.startTest();
        Date myDate = parser.getDate('dateOfBirth');
        Test.stopTest();

        System.assertEquals(Date.newInstance(1988, 5, 13), myDate, 'Date was wrong');
    }

    @IsTest
    static void testGetDatetime() {
        JsonUntypedParser parser = new JsonUntypedParser(getMockJson());

        Test.startTest();
        Datetime myDatetime = parser.getDatetime('now');
        Test.stopTest();

        System.assertEquals(Datetime.newInstanceGmt(2013, 10, 21, 13, 28, 6), myDatetime, 'Datetime was wrong');
    }

    @IsTest
    static void testGetBoolean() {
        JsonUntypedParser parser = new JsonUntypedParser(getMockJson());

        Test.startTest();
        Boolean isShipped = parser.getBoolean('isShipped');
        Test.stopTest();
        
        System.assert(isShipped, 'Boolean was wrong');
    }

    @IsTest
    static void testGetInteger() {
        JsonUntypedParser parser = new JsonUntypedParser(getMockJson());

        Test.startTest();
        Integer inventory = parser.getInteger('inventory');
        Test.stopTest();
        
        System.assertEquals(2000, inventory, 'Integer was wrong');
    }

    @IsTest
    static void testGetLong() {
        JsonUntypedParser parser = new JsonUntypedParser(getMockJson());

        Test.startTest();
        Long inventory = parser.getLong('inventory');
        Test.stopTest();
        
        System.assertEquals(2000, inventory, 'Long was wrong');
    }

    @IsTest
    static void testGetString() {
        JsonUntypedParser parser = new JsonUntypedParser(getMockJson());

        Test.startTest();
        String accessory = parser.getString('accessories[1].right');
        Test.stopTest();

        System.assertEquals('door handle1', accessory, 'String was wrong');
    }

    @IsTest
    static void testGetDouble() {
        JsonUntypedParser parser = new JsonUntypedParser(getMockJson());

        Test.startTest();
        Double height = parser.getDouble('dimensions.height');
        Test.stopTest();

        System.assertEquals(5.5, height, 'Double was wrong');
    }

    @IsTest
    static void testGetDecimal() {
        JsonUntypedParser parser = new JsonUntypedParser(getMockJson());

        Test.startTest();
        Decimal height = parser.getDecimal('dimensions.height');
        Test.stopTest();

        System.assertEquals(5.5, height, 'Decimal was wrong');
    }

    @IsTest
    static void testGetId() {
        JsonUntypedParser parser = new JsonUntypedParser(getMockJson());

        Test.startTest();
        Id sid = parser.getId('sid');
        Test.stopTest();

        System.assertEquals(Opportunity.getSObjectType(), sid.getSobjectType(), 'Id was wrong');
    }

    @IsTest
    static void testGetTime() {
        JsonUntypedParser parser = new JsonUntypedParser(getMockJson());

        Test.startTest();
        Time arrivalTime = parser.getTime('arrivalTime');
        Test.stopTest();

        System.assertEquals(Time.newInstance(18, 5, 0, 0).minute(), arrivalTime.minute(), 'Time was wrong');
    }
}