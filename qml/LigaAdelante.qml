import QtQuick 2.0
import Ubuntu.Components 1.2

Page {
    id:mainPage
    title: i18n.tr("resultados Adelante")


    Component.onCompleted: creaModelo();

    function creaModelo(){
        var index = 0;
        while (typeof resultsAdelanteModelSinOrden.get(index).docId !== "undefined"){
            var sResult = JSON.stringify(resultsAdelanteModelSinOrden.get(index));
            console.log(sResult);
            var result= JSON.parse(sResult);
            resultsAdelanteCalculado.append({"awayTeam": result.contents.awayTeam,
                                            "date":result.contents.date,
                                            "sortableDate":getsortableDate(result.contents.date),
                                            "ftag": result.contents.ftag,
                                            "fthg": result.contents.fthg,
                                            "ftr": result.contents.ftr,
                                            "homeTeam": result.contents.homeTeam});
            index++;
        }
    }

    function getsortableDate(date){
        var sortableDate = date.substring(6,8);
        sortableDate = sortableDate.concat(date.substring(3,5));
        sortableDate = sortableDate.concat(date.substring(0,2));
        console.debug(sortableDate);
        return sortableDate;
    }

    head.actions :[
        Action {
            id: reloadAction
            iconName: "reload"
            text: "reload"
            onTriggered: readCSV.sendMessage({"url":"http://www.football-data.co.uk/mmz4281/1516/SP2.csv"});
        }
    ]

    ListModel {
        id: resultsAdelanteCalculado
        ListElement{awayTeam:"";date:"";sortableDate:"morralla";ftag:"";fthg:"";ftr:"";homeTeam:""}
    }

    SortFilterModel {
        id:resultsAdelanteModel
        model: resultsAdelanteCalculado
        sort.property: "sortableDate"
        sortCaseSensitivity:Qt.CaseInsensitive
        sort.order: Qt.AscendingOrder
        //to do this for "bug". If we don't add a initial ListElement the SortFilterModel don't sort
        filter.property: "sortableDate"
        filter.pattern:/^((?!morralla).)*$/
    }

    ListView {
        id:adelanteResults
        anchors.fill: parent
        clip: true
        model: resultsAdelanteModel//adelanteModel
        delegate: resultDelegate
        header: Rectangle {
            width: parent.width;
            height: units.gu(1)
            color: "#333333"
        }

        footer: Rectangle {
            width: parent.width
            height: units.gu(1)
            color: "#333333"
        }
    }


    Component {
        id:resultDelegate
            Text{
                Label {
                    text: date +" - "+ homeTeam+" - "+ awayTeam +" - "+ fthg +" - "+ ftag
                }
            }
        }


    WorkerScript{
        id:readCSV
        source: "../js/readAdelanteMatches.js"
        onMessage: {
            console.log("recibido mensaje "+messageObject.matches.length);
            for (var i = 0; i < messageObject.matches.length; i++) {
                var match= messageObject.matches[i];
                console.log(match.date);
                addResult(match.div, match.date, match.homeTeam, match.awayTeam, match.fthg, match.ftag, match.ftr);
            }
        }
    }
}
