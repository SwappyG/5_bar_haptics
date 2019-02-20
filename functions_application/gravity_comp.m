function boost = gravity_comp(angle, K_spring, K_gravity)

    boost = K_spring * ( sin(angle)/K_gravity - angle );

end