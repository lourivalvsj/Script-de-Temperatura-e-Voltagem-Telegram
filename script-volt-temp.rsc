# ==============================
# Monitoramento de Voltagem e Temperatura - RouterOS
# Envia alertas via Telegram somente quando mudar de estado
# ==============================

# ----- Configurações do Telegram -----
:global bottoken "SEU_BOT_TOKEN_AQUI"      # Token do bot do Telegram
:global chatid1 "SEU_CHAT_ID_1_AQUI"       # ID do primeiro chat/grupo
:global chatid2 "SEU_CHAT_ID_2_AQUI"       # ID do segundo chat/grupo

# Variáveis globais
:global voltagem [/system health get voltage]
:global temperatura [/system health get temperature]

# ----- Limites configuráveis -----
# Voltagem
:global lowvolt 200     # mínimo aceitável (ex.: 200V)
:global highvolt 240    # máximo aceitável (ex.: 240V)
:global lastvoltstate   # guarda último estado de voltagem

# Temperatura
:global lowtemp 20      # mínima aceitável (ex.: 20°C)
:global hightemp 60     # máxima aceitável (ex.: 60°C)
:global lasttempstate   # guarda último estado de temperatura

# Identificação do roteador
:local thisbox [/system identity get name]

# Data/hora
:local thistime [/system clock get time]
:local thisdate [/system clock get date]

# ==============================
# Função para enviar mensagem
# ==============================
:local sendMessage do={
    :local texto ($1)
    :local chatid ($2)
    [/tool fetch url="https://api.telegram.org/bot$bottoken/sendMessage?chat_id=$chatid&text=[$thisdate $thistime] $thisbox $texto"]
}

# ==============================
# Verificação da Voltagem
# ==============================
:local voltstate "normal"

:if ($voltagem < $lowvolt) do={ :set voltstate "baixa" }
:if ($voltagem > $highvolt) do={ :set voltstate "alta" }

# Só envia se mudou de estado
:if ($voltstate != $lastvoltstate) do={
    :if ($voltstate = "baixa") do={
        $sendMessage ("Voltagem: $voltagem V (⚠️ Muito Baixa)") $chatid1
        $sendMessage ("Voltagem: $voltagem V (⚠️ Muito Baixa)") $chatid2
    }
    :if ($voltstate = "alta") do={
        $sendMessage ("Voltagem: $voltagem V (⚠️ Muito Alta)") $chatid1
        $sendMessage ("Voltagem: $voltagem V (⚠️ Muito Alta)") $chatid2
    }
    :if ($voltstate = "normal") do={
        $sendMessage ("Voltagem: $voltagem V (✅ Normal)") $chatid1
        $sendMessage ("Voltagem: $voltagem V (✅ Normal)") $chatid2
    }
    :set lastvoltstate $voltstate
}

# ==============================
# Verificação da Temperatura
# ==============================
:local tempstate "normal"

:if ($temperatura < $lowtemp) do={ :set tempstate "baixa" }
:if ($temperatura > $hightemp) do={ :set tempstate "alta" }

# Só envia se mudou de estado
:if ($tempstate != $lasttempstate) do={
    :if ($tempstate = "baixa") do={
        $sendMessage ("Temperatura: $temperatura °C (🧊 Muito Baixa)") $chatid1
        $sendMessage ("Temperatura: $temperatura °C (🧊 Muito Baixa)") $chatid2
    }
    :if ($tempstate = "alta") do={
        $sendMessage ("Temperatura: $temperatura °C (🔥 Muito Alta)") $chatid1
        $sendMessage ("Temperatura: $temperatura °C (🔥 Muito Alta)") $chatid2
    }
    :if ($tempstate = "normal") do={
        $sendMessage ("Temperatura: $temperatura °C (✅ Normal)") $chatid1
        $sendMessage ("Temperatura: $temperatura °C (✅ Normal)") $chatid2
    }
    :set lasttempstate $tempstate
}
