function def_sim = dau1997_cfg(keyvals)

def_sim.modelname = 'dau1997';
def_sim.decision_script = 'aci_detect';
def_sim.template_script = 'model_template';
def_sim.template_every_trial = 0;
def_sim.templ_num = 10;
def_sim.det_lev = -6;
def_sim.type_decision = 'optimal_detector';
switch def_sim.type_decision
  case 'optimal_detector'
    optdet_params = optimal_detector_cfg(def_sim.modelname,keyvals);
    def_sim.thres_for_bias = optdet_params.thres_for_bias;
    def_sim.in_var = optdet_params.in_var;
end
def_sim.bStore_template = 1;

if exist('model_cfg.m','file')
    % Config: AFC toolbox
    global def
    
    model_cfg;
end
