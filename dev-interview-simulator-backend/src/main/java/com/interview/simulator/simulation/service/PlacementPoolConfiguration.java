package com.interview.simulator.simulation.service;

import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class PlacementPoolConfiguration {

    public record QuestionIdentity(String title, String contentHash) {}

    public static final List<QuestionIdentity> Q1 = List.of(
        new QuestionIdentity("Comparaison de jetons de session avec ==",
            "559c849fa23d7adad0a3bc6446c667826e905870d2f9924ad93992faf432fdd6"),
        new QuestionIdentity("Fichier jamais fermé après une exception",
            "eb2a636ed6e0d2a8c363fb0c9b9471631558dd8a32c3617bfb9c8c772f1cb509"),
        new QuestionIdentity("NullPointerException sur une comparaison",
            "95d237053056eb204a9dd49e1dde0b167eb38d87626a781301f9c588841bc3d8"),
        new QuestionIdentity("Total tronqué dans un rapport",
            "1a9b1566adcb2b0ac289c73870d48c08accc48a69defc13734f7c52eb753e854"),
        new QuestionIdentity("Bases Java : HashSet ou HashMap ?",
            "b6ab1f06c3f1d98743bd26de0c04113a759f4189624e45ac9b2e074745620d32"),
        new QuestionIdentity("Bases Java : lire une chaîne de Stream",
            "4fa9359c59474fb774c4b0696a82db0c1bb875a4dc329d0dfd921a556c779ae6"),
        new QuestionIdentity("Bases Java : String ou StringBuilder ?",
            "3851b0806d82c7384a21023e23ea7032bcde932c9231ff4f24ec2c32369120e7")
    );

    public static final List<QuestionIdentity> Q2 = List.of(
        new QuestionIdentity("Requête lente sur une grosse table",
            "8b10dd0fabb99585972a3357993967dc85a6f19af4b9e3a90531be25c30e9a25"),
        new QuestionIdentity("Requête trop lente sur grande table",
            "35e6e7e9594d9df0882bf59ffddcc63889159ffe6c3849010defd91bedd2c210"),
        new QuestionIdentity("Jointure qui retourne trop de lignes",
            "bac97d0041e72122555a01930bbbb8a962cc0bdc5ff33de450a6eb7649c177b8")
    );

    public static final List<QuestionIdentity> Q4 = List.of(
        new QuestionIdentity("Review Spring : client HTTP sans timeout",
            "3190d8425fe809546b29523788b4eb8c7a83bf131c8d3060adb4dec8dad9f26e"),
        new QuestionIdentity("Review Spring : erreur renvoyée en 200",
            "96851060b3516d29a91a6a0581f0b27324fb71d525fa6feb5c2d03e5d8e70dd1"),
        new QuestionIdentity("Review Spring : log de données sensibles",
            "773b75bb61db6d1932068c4ff488a2d3a1c24d5c7b31ae025ce3d88f632cd9f2e"),
        new QuestionIdentity("API Review : liste sans pagination",
            "96d67f9b1a4461239ee894f7efbca0163716c8c6a30e9667b59eb7e53f1"),
        new QuestionIdentity("SQL Review : pagination pendant écritures concurrentes",
            "2aff9b09c6ace4e0aba0285765db03399d00a1876c10bed22808f8ac6d43f479"),
        new QuestionIdentity("JPA Review : @Lob en EAGER sur une entité listée",
            "2ad3927b447bc75ab8dfd58a2bf7f0a3bff25b3d784f7a7cba9123ec138707d5")
    );

    public static final List<QuestionIdentity> Q3 = List.of(
        new QuestionIdentity("Spring : appel interne et @Transactional",
            "42dc2069a0650c1aeab30cf8f464068b73231a9b61d7805b904a6ada8af52bc2"),
        new QuestionIdentity("Spring : transaction longue qui grève le pool",
            "d700413320f89e5714cc11d7210d8f1be904536943a3b4ef77f5c9bfa2468f4c"),
        new QuestionIdentity("Spring : LazyInitializationException",
            "0975c07376b5fdd73c0e7a1352768a8e935553931d8bc10d79cc7b9800b191f2")
    );

    public static final List<QuestionIdentity> Q5 = List.of(
        new QuestionIdentity("API : isolation multi-tenant et IDOR",
            "e7ef9f98260b50df189cd9b5bb3a5b90b359474a758a39426991819773a6cf1f"),
        new QuestionIdentity("Spring : migration jakarta.* après saut de version",
            "4640da8b36caa33e63e64b51e82ec31b94a2cb85593710ce5d766324dac848af"),
        new QuestionIdentity("SQL : anomalies de sérialisation sous forte charge",
            "117fdc31c1e48bf5dd88ae08a1d071f75ee1fc98811df18f3fa37d0d7bc97210")
    );
}
