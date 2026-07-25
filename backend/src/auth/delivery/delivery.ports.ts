export const SMS_DELIVERY_PORT = Symbol('SMS_DELIVERY_PORT');

export interface SmsDeliveryPort {
  sendOtp(input: {
    destinationE164: string;
    purpose: string;
    code: string;
    expiresAt: Date;
  }): Promise<void>;
}
