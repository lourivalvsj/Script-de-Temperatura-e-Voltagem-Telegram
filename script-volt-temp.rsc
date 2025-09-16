# ==============================
# Monitoramento de Voltagem e Temperatura - RouterOS
# Envia alertas via Telegram somente quando mudar de estado
# ==============================
# 
# Desenvolvedor: Lourival Vicente
# GitHub: @lourivalvsj
# Repositório: Script-de-Temperatura-e-Voltagem-Telegram
# Data de Criação: Setembro 2025
# Versão: 1.0
# 
# Descrição:
# Script para monitoramento automático de voltagem e temperatura
# em equipamentos RouterOS, com notificações via Telegram Bot.
# Envia alertas apenas quando há mudança de estado, evitando spam.
# 
# Recursos:
# - Monitoramento contínuo de voltagem e temperatura
# - Envio para múltiplos chats/grupos do Telegram
# - Detecção de mudança de estado (normal/alta/baixa)
# - Configuração flexível de limites
# - Compatibilidade total com RouterOS
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

# Log de inicio da execução
:log info "MONITORAMENTO INICIADO: Voltagem=$voltagem V | Temperatura=$temperatura C | [$thisdate $thistime]"

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
    # Log da mudança de estado
    :log info "VOLTAGEM: Mudanca de estado de '$lastvoltstate' para '$voltstate' - Valor: $voltagem V"
    
    :if ($voltstate = "baixa") do={
        $sendMessage ("Voltagem: $voltagem V [ALERTA] Muito Baixa") $chatid1
        $sendMessage ("Voltagem: $voltagem V [ALERTA] Muito Baixa") $chatid2
        :log warning "VOLTAGEM CRITICA: $voltagem V - Abaixo do limite minimo ($lowvolt V)"
    }
    :if ($voltstate = "alta") do={
        $sendMessage ("Voltagem: $voltagem V [ALERTA] Muito Alta") $chatid1
        $sendMessage ("Voltagem: $voltagem V [ALERTA] Muito Alta") $chatid2
        :log warning "VOLTAGEM CRITICA: $voltagem V - Acima do limite maximo ($highvolt V)"
    }
    :if ($voltstate = "normal") do={
        $sendMessage ("Voltagem: $voltagem V [OK] Normal") $chatid1
        $sendMessage ("Voltagem: $voltagem V [OK] Normal") $chatid2
        :log info "VOLTAGEM NORMALIZADA: $voltagem V - Dentro dos limites ($lowvolt V - $highvolt V)"
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
    # Log da mudança de estado
    :log info "TEMPERATURA: Mudanca de estado de '$lasttempstate' para '$tempstate' - Valor: $temperatura C"
    
    :if ($tempstate = "baixa") do={
        $sendMessage ("Temperatura: $temperatura C [ALERTA] Muito Baixa") $chatid1
        $sendMessage ("Temperatura: $temperatura C [ALERTA] Muito Baixa") $chatid2
        :log warning "TEMPERATURA CRITICA: $temperatura C - Abaixo do limite minimo ($lowtemp C)"
    }
    :if ($tempstate = "alta") do={
        $sendMessage ("Temperatura: $temperatura C [ALERTA] Muito Alta") $chatid1
        $sendMessage ("Temperatura: $temperatura C [ALERTA] Muito Alta") $chatid2
        :log warning "TEMPERATURA CRITICA: $temperatura C - Acima do limite maximo ($hightemp C)"
    }
    :if ($tempstate = "normal") do={
        $sendMessage ("Temperatura: $temperatura C [OK] Normal") $chatid1
        $sendMessage ("Temperatura: $temperatura C [OK] Normal") $chatid2
        :log info "TEMPERATURA NORMALIZADA: $temperatura C - Dentro dos limites ($lowtemp C - $hightemp C)"
    }
    :set lasttempstate $tempstate
}
