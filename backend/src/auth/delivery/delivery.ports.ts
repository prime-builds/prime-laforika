export const SMS_DELIVERY_PORT = Symbol('SMS_DELIVERY_PORT');
export const EMAIL_DELIVERY_PORT = Symbol('EMAIL_DELIVERY_PORT');

export interface SmsDeliveryPort {
  sendOtp(input: {
    destinationE164: string;
    purpose: string;
    code: string;
    expiresAt: Date;
  }): Promise<void>;
}

export interface EmailDeliveryPort {
  sendCode(input: {
    destinationEmail: string;
    purpose: string;
    code: string;
    expiresAt: Date;
  }): Promise<void>;
}
