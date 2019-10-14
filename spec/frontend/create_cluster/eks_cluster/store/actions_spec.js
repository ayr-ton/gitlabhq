import testAction from 'helpers/vuex_action_helper';

import createState from '~/create_cluster/eks_cluster/store/state';
import * as actions from '~/create_cluster/eks_cluster/store/actions';
import {
  SET_REGION,
  SET_VPC,
  SET_KEY_PAIR,
  SET_SUBNET,
  SET_ROLE,
} from '~/create_cluster/eks_cluster/store/mutation_types';

describe('EKS Cluster Store Actions', () => {
  let region;
  let vpc;
  let subnet;
  let role;
  let keyPair;

  beforeEach(() => {
    region = { name: 'regions-1' };
    vpc = { name: 'vpc-1' };
    subnet = { name: 'subnet-1' };
    role = { name: 'role-1' };
    keyPair = { name: 'key-pair-1' };
  });

  it.each`
    action          | mutation        | payload        | payloadDescription
    ${'setRole'}    | ${SET_ROLE}     | ${{ role }}    | ${'role'}
    ${'setRegion'}  | ${SET_REGION}   | ${{ region }}  | ${'region'}
    ${'setKeyPair'} | ${SET_KEY_PAIR} | ${{ keyPair }} | ${'key pair'}
    ${'setVpc'}     | ${SET_VPC}      | ${{ vpc }}     | ${'vpc'}
    ${'setSubnet'}  | ${SET_SUBNET}   | ${{ subnet }}  | ${'subnet'}
  `(`$action commits $mutation with $payloadDescription payload`, data => {
    const { action, mutation, payload } = data;

    testAction(actions[action], payload, createState(), [{ type: mutation, payload }]);
  });
});