#!/bin/bash

#==============================================================================
# Lazy Loader - v3.0 - Compatible Bash 3+ et chemins de modules complets
#==============================================================================

_loaded_modules=""

is_module_loaded() {
    local module_path="$1"
    if [[ ",${_loaded_modules}," == *",${module_path},"* ]]; then
        return 0
    else
        return 1
    fi
}

load_module() {
    local module_path="$1"
    
    if is_module_loaded "$module_path"; then
        return 0
    fi
    
    local full_path="${AKLO_PROJECT_ROOT}/aklo/modules/${module_path}.sh"
    
    if [ -f "$full_path" ]; then
        # shellcheck source=/dev/null
        source "$full_path"
        _loaded_modules="${_loaded_modules},${module_path}"
    else
        echo "Attention: Module non trouvé à l'emplacement '$full_path'." >&2
    fi
}

load_modules_for_profile() {
    local profile="$1"
    
    local modules_to_load
    modules_to_load=$(get_required_modules "$profile")
    
    for module in ${modules_to_load//,/ }; do
        load_module "$module"
    done
}