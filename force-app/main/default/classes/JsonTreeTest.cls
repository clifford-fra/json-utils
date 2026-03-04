/**
 * @File Name          : JsonTreeTest.cls
 * @Description        : test class forr JsonTree
 * @Author             : Clifford Beul
 * @Last Modified By   : c.beul
 * @Last Modified On   : 15.4.2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0       15.4.2021       c.beul                 Initial Version
**/
@IsTest
public class JsonTreeTest {

    @IsTest
    static void testbuild() {

        /* Test JSON:
        {
            "Send Date":"17.04.2021",
            "Creation Date":"17.04.2021",
            "Person":{
                "Details":{
                    "Name":"Beul",
                    "Vorname":"Clifford",
                    "Wohnort":"Frankfurt"
                },
                "Qualifikation":{
                    "Hochschulabschluss":true
                }
            },
            "Studium":{
                "Kurs":"Winf B.Sc.",
                "CP":180,
                "Wunschbeginn":"WS 2022"
            }
        }
        */

        JSONTree tree = new JSONTree();
        tree.sink('Person.Details', 'Name', 'Beul');
        tree.sink('Person.Details', 'Vorname', 'Clifford');
        tree.sink('Person.Details.Wohnort', 'Frankfurt'); // Short Syntax
        tree.sink('Person.Qualifikation', 'Hochschulabschluss', true);
        tree.sink('Studium', 'Kurs', 'Winf B.Sc.');
        tree.sink('Studium', 'CP', 180);
        tree.sink('Studium', 'Wunschbeginn', 'WS 2022');
        tree.sink('Send Date', Date.today().format()); // Short Syntax
        tree.sink('', 'Creation Date', Date.today().format());
        String jsonString = tree.build();
        System.debug(jsonString);

        // Testing the result
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        System.assertEquals(Date.today().format(), results.get('Send Date'));
        System.assertEquals(Date.today().format(), results.get('Creation Date'));

        Map<String, Object> studiumResults = (Map<String, Object>) results.get('Studium');
        System.assertEquals('Winf B.Sc.', studiumResults.get('Kurs'));
        System.assertEquals(180, studiumResults.get('CP'));
        System.assertEquals('WS 2022', studiumResults.get('Wunschbeginn'));

        Map<String, Object> personResults = (Map<String, Object>) results.get('Person');

        Map<String, Object> personDetails = (Map<String, Object>) personResults.get('Details');
        System.assertEquals('Beul', personDetails.get('Name'));
        System.assertEquals('Clifford', personDetails.get('Vorname'));
        System.assertEquals('Frankfurt', personDetails.get('Wohnort'));

        Map<String, Object> personQualifikation = (Map<String, Object>) personResults.get('Qualifikation');
        System.assertEquals(true, personQualifikation.get('Hochschulabschluss'));
    }
}