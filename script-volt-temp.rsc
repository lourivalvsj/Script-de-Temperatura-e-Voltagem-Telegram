# ==============================
# Monitoramento de Voltagem e Temperatura - RouterOS
# Envia alertas via Telegram somente quando mudar de estado
# ==============================

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

[/tool fetch url="https://api.telegram.org/botXXXX/sendMessage?chat_id=XXXX&text=[$thisdate $thistime] $thisbox $texto"]


# ==============================
# Função para enviar mensagem
# ==============================
:local sendMessage do={
    :local texto ($1)
    :local chat ($2)
    [/tool fetch url="https://api.telegram.org/botXXXX/sendMessage?chat_id=XXXX&text=[$thisdate $thistime] $thisbox $texto"]
}

[/tool fetch url="https://api.telegram.org/botXXXX/sendMessage?chat_id=XXXX&text=[$thisdate $thistime] $thisbox $texto"]
# ==============================
# Verificação da Voltagem
# ==============================
:local voltstate "normal"

:if ($voltagem < $lowvolt) do={ :set voltstate "baixa" }
:if ($voltagem > $highvolt) do={ :set voltstate "alta" }

# Só envia se mudou de estado
:if ($voltstate != $lastvoltstate) do={
    :if ($voltstate = "baixa") do={
        $sendMessage ("Voltagem: $voltagem V (?? Muito Baixa)") "XXXX"
    }
    :if ($voltstate = "alta") do={
        $sendMessage ("Voltagem: $voltagem V (?? Muito Alta)") "XXXX"
    }
    :if ($voltstate = "normal") do={
        $sendMessage ("Voltagem: $voltagem V (? Normal)") "XXXX"
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
        $sendMessage ("Temperatura: $temperatura °C (?? Muito Baixa)") "XXXX"
    }
    :if ($tempstate = "alta") do={
        $sendMessage ("Temperatura: $temperatura °C (?? Muito Alta)") "XXXX"
    }
    :if ($tempstate = "normal") do={
        $sendMessage ("Temperatura: $temperatura °C (? Normal)") "XXXX"
    }
    :set lasttempstate $tempstate
}
