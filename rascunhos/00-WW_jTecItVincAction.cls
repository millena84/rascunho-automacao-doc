public class WW_jTecItVincAction {

    // -------- ENTRADA DO FLOW --------
    public class vinculosEntrada {
        @InvocableVariable(required=true)
        public Id vincId;          // Id WW2_VincComuItemBrfMktItem__c

        @InvocableVariable(required=true)
        public Id comuItemId;      // Id WW2_Comunicacao_Item__c

        @InvocableVariable(required=true)
        public Id brfMktItemId;    // Id WW2_Briefing_Marketing_Item__c

        @InvocableVariable(required=true)
        public Id canalId;         // Id WW2_Canal__c (se já vier do Flow)
    }

    public class Request {
        @InvocableVariable(required=true)
        public Id jornadaTecnicaId;           // Id WW2_Jornada_Tecnica__c

        @InvocableVariable(required=true)
        public List<vinculosEntrada> vinculos; // lista de VINCs
    }

    // -------- SAÍDA PARA O FLOW / AGENTE --------
    public class Resultado {
        @InvocableVariable
        public String mensagem;
        @InvocableVariable
        public Integer totalCriados;
        @InvocableVariable
        public Id jornadaTecnicaIdProcessado;

        public Resultado(String msg, Integer total, Id jtId) {
            mensagem                    = msg;
            totalCriados                = total;
            jornadaTecnicaIdProcessado  = jtId;
        }
    }

    @InvocableMethod(
        label='Processar WW2_Jornada_Tecnica e criar WW2_Jornada_Tecnica_Item__c'
        description='Recebe Jornada Tecnica e VINCs, grava WW2_Jornada_Tecnica_Item__c'
    )
    public static List<Resultado> processarJornadaTecnica(List<Request> requests) {
        List<Resultado> resultados = new List<Resultado>();
        if (requests == null || requests.isEmpty()) {
            return resultados;
        }

        Request req = requests[0];

        // 1) Jornada Técnica + tipo
        WW2_Jornada_Tecnica__c jornadaTecnica = [
            SELECT Id, Name, WW2_Tipo_Jornada__r.Name
            FROM WW2_Jornada_Tecnica__c
            WHERE Id = :req.jornadaTecnicaId
            LIMIT 1
        ]; [web:24][web:31]

        String tipoJornadaName = jornadaTecnica.WW2_Tipo_Jornada__r != null
            ? jornadaTecnica.WW2_Tipo_Jornada__r.Name
            : null;

        // 2) IDs de VINC
        Set<Id> vincsIds = new Set<Id>();
        for (vinculosEntrada vIn : req.vinculos) {
            if (vIn != null && vIn.vincId != null) {
                vincsIds.add(vIn.vincId);
            }
        }

        // 2.1) VINCs com canal
        Map<Id, WW2_VincComuItemBrfMktItem__c> vincById =
            new Map<Id, WW2_VincComuItemBrfMktItem__c>(
                [
                    SELECT Id,
                           WW2_Canal__c,
                           WW2_Canal__r.Name
                    FROM WW2_VincComuItemBrfMktItem__c
                    WHERE Id IN :vincsIds
                ]
            ); [web:24][web:31]

        // 3) Para cada VINC, faz de‑para e cria JTI
        List<WW2_Jornada_Tecnica_Item__c> novosJTI = new List<WW2_Jornada_Tecnica_Item__c>();

        for (vinculosEntrada vIn : req.vinculos) {
            if (vIn == null || vIn.vincId == null) continue;

            WW2_VincComuItemBrfMktItem__c vinculo = vincById.get(vIn.vincId);
            String nmCanal = (vinculo != null && vinculo.WW2_Canal__r != null)
                ? vinculo.WW2_Canal__r.Name
                : null;

            Map<String,String> deParaVars = new Map<String,String>();

            if (tipoJornadaName != null) {
                if (tipoJornadaName.contains('JORNADA')) {
                    deParaVars = deParaJornada(nmCanal);
                } else if (tipoJornadaName.contains('CAMPANHA')) {
                    deParaVars = deParaCampanha(nmCanal);
                } else if (tipoJornadaName.contains('VAI')) {
                    deParaVars = deParaVai(nmCanal);
                }
            }

            if (deParaVars.isEmpty()) {
                // se não achou de‑para, pula este VINC
                continue;
            }

            String grupoId  = buscarRecordIdAtivo('WW2_Grupo_Atividade__c',       deParaVars.get('var_nm_grupo_atv'));
            String itemId   = buscarRecordIdAtivo('WW2_Item_Atividade__c',        deParaVars.get('var_nm_item_atv'));
            String propriId = buscarRecordIdAtivo('WW2_Propriedade_Atividade__c', deParaVars.get('var_nm_prop_atv'));

            WW2_Jornada_Tecnica_Item__c jti = new WW2_Jornada_Tecnica_Item__c(
                WW2_Jornada_Tecnica__c         = jornadaTecnica.Id,
                WW2_Grupo_Atividade__c         = grupoId,
                WW2_Item_Atividade__c          = itemId,
                WW2_Propriedade_Atividade__c   = propriId,
                WW2_VincComuItemBrfMktItem__c  = vIn.vincId,
                WW2_Briefing_Marketing_Item__c = vIn.brfMktItemId
            );
            novosJTI.add(jti);
        }

        if (!novosJTI.isEmpty()) {
            insert novosJTI;
        }

        resultados.add(
            new Resultado(
                'Processamento concluído com sucesso.',
                novosJTI.size(),
                jornadaTecnica.Id
            )
        );

        return resultados;
    }

    // -------- DE‑PARA JORNADA --------
    public static Map<String,String> deParaJornada(String nmCanal) {
        Map<String,String> vars = new Map<String,String>();
        if (String.isBlank(nmCanal)) {
            return vars;
        }

        String canalUpper = nmCanal.toUpperCase();

        if (canalUpper == 'EML') {
            vars.put('var_nm_grupo_atv', 'MENSAGEM');
            vars.put('var_nm_item_atv',  'EMAIL');
            vars.put('var_nm_prop_atv',  'NOME');
        } else if (canalUpper == 'SMS') {
            vars.put('var_nm_grupo_atv', 'MENSAGEM');
            vars.put('var_nm_item_atv',  'SMS');
            vars.put('var_nm_prop_atv',  'NOME');
        } else if (canalUpper == 'PCME') {
            vars.put('var_nm_grupo_atv', 'MENSAGEM');
            vars.put('var_nm_item_atv',  'PCME');
            vars.put('var_nm_prop_atv',  'NOME');
        }

        return vars;
    }

    // -------- DE‑PARA CAMPANHA --------
    public static Map<String,String> deParaCampanha(String nmCanal) {
        Map<String,String> vars = new Map<String,String>();
        if (String.isBlank(nmCanal)) {
            return vars;
        }

        String canalUpper = nmCanal.toUpperCase();

        if (canalUpper == 'MBL' || canalUpper == 'BKL' || canalUpper == 'DSP') {
            vars.put('var_nm_grupo_atv', 'AD MANAGER');
            vars.put('var_nm_item_atv',  'LINE ITEM');
            vars.put('var_nm_prop_atv',  'NOME');
        }

        return vars;
    }

    // -------- DE‑PARA VAI --------
    public static Map<String,String> deParaVai(String nmCanal) {
        Map<String,String> vars = new Map<String,String>();
        if (String.isBlank(nmCanal)) {
            return vars;
        }

        String canalUpper = nmCanal.toUpperCase();

        if (canalUpper == 'FOI') {
            vars.put('var_nm_grupo_atv', 'FOI');
            vars.put('var_nm_item_atv',  'FOI');
            vars.put('var_nm_prop_atv',  'NOME');
        }

        return vars;
    }

    // -------- BUSCA PARÂMETROS ATIVIDADE --------
    public static String buscarRecordIdAtivo(String objectName, String nomeCampo) {
        if (String.isBlank(objectName) || String.isBlank(nomeCampo)) {
            return null;
        }

        String escapedName = String.escapeSingleQuotes(nomeCampo); [web:19]
        String soql = 'SELECT Id FROM ' + objectName +
                      ' WHERE Name = \'' + escapedName + '\' LIMIT 1';
        List<SObject> results = Database.query(soql); [web:10]

        if (!results.isEmpty()) {
            return (String)results[0].get('Id');
        }

        return null;
    }
}
